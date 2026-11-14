#include <libflexio-dev/flexio_dev_ver.h>
#define FLEXIO_DEV_VER_USED FLEXIO_DEV_VER(26, 4, 0)
#include <libflexio-dev/flexio_dev.h>
#include <libflexio-dev/flexio_dev_queue_access.h>
#include <dpaintrin.h>
#include <stddef.h>
#include "../common.h"
#include "../../model-compiler/model.h"

#define NN_FEATURES 10
#define NN_THRESHOLD (1 << (NN_SHIFT - 1))

static inline uint16_t read_u16(const uint8_t *p) {
	uint16_t v;
	__builtin_memcpy(&v, p, sizeof(v));
	return be16_to_cpu(v);
}

static inline uint32_t read_u32(const uint8_t *p) {
	uint32_t v;
	__builtin_memcpy(&v, p, sizeof(v));
	return be32_to_cpu(v);
}

static void parse_five_tuple(const uint8_t *pkt, uint32_t len, struct five_tuple *t) {
	const uint8_t *ip = pkt + ETH_HDR_LEN;
	uint32_t ip_hdr_len = (ip[0] & 0xf) * 4;

	t->proto    = ip[IP_PROTO];
	t->src_ip   = read_u32(ip + IP_SRC);
	t->dst_ip   = read_u32(ip + IP_DST);
	t->src_port = 0;
	t->dst_port = 0;

	if ((t->proto == IPPROTO_TCP || t->proto == IPPROTO_UDP) && !(read_u16(ip + IP_FRAG) & IP_FRAG_OFFSET) && ip_hdr_len >= 20 && len >= ETH_HDR_LEN + ip_hdr_len + 4) {
		t->src_port = read_u16(ip + ip_hdr_len);
		t->dst_port = read_u16(ip + ip_hdr_len + 2);
		t->rst = ip[ip_hdr_len + 13] & 0x04;
		t->psh = ip[ip_hdr_len + 13] & 0x08;
		t->fin = ip[ip_hdr_len + 13] & 0x01;
	}

	if (t->src_ip > t->dst_ip || (t->src_ip == t->dst_ip && t->src_port > t->dst_port)) {
		uint32_t ip_tmp = t->src_ip;
		uint16_t port_tmp = t->src_port;

		t->src_ip = t->dst_ip;
		t->dst_ip = ip_tmp;
		t->src_port = t->dst_port;
		t->dst_port = port_tmp;
	}
}

static inline int flow_expired(const struct flow *f, uint32_t now) {
	if (f->state != FLOW_STATE_NEW && now - f->last_seen > 10000000) { // 10 seconds
		return 1;
	}
	else {
		return 0;
	}
}

static void flow_free(struct pkt_ctx *c, struct flow *f) {
	c->used--;
	f->state = FLOW_STATE_NEW;
}

static int tuple_eq(const struct five_tuple *a, const struct five_tuple *b) {
	return a->src_ip == b->src_ip && a->dst_ip == b->dst_ip && a->src_port == b->src_port && a->dst_port == b->dst_port && a->proto == b->proto;
}

static struct flow *flow_update(struct pkt_ctx *c, const struct five_tuple *t, uint32_t hash) {
	int index = hash & FLOW_MASK & ~(FLOW_BUCKET_SIZE - 1);
	struct flow *bucket = (struct flow *)c->flows + index;
	struct flow *free_slot = NULL;

	for (unsigned int i = 0; i < FLOW_BUCKET_SIZE; i++) {
		struct flow *f = &bucket[i];

		if (flow_expired(f, (uint32_t)__dpa_thread_time())) {
			flow_free(c, f);
		}

		if (f->state == FLOW_STATE_NEW) {
			if (free_slot == NULL) {
				free_slot = f; // wir merken uns nur den ersten freien Slot, suchen aber weiter, um zu prüfen, ob der Flow später im Bucket schon existiert
			}
		} else if (f->hash == hash && tuple_eq(&f->t, t)) {
			return f; // return a flow that is known
		}
	}
	if (free_slot != NULL) {
		struct flow *f = free_slot;
		f->state = FLOW_STATE_KNOWN;
		f->t = *t;
		f->hash = hash;
		f->total_bytes = 0;
		f->total_pkts = 0;
		f->iat_min = 0;
		f->iat_max = 0;
		f->iat_sum = 0;
		f->last_seen = 0;
		f->rst_count = 0;
		f->psh_count = 0;
		f->fin_count = 0;
		f->pkt_min = 0xffff;
		f->pkt_max = 0;
		f->suspicion_score = 0;
		c->used++;
		return f;
	}
	c->collisions++;
	return NULL;
}

static inline int16_t f_lin(uint32_t v, unsigned shift) {
	return v > ((uint32_t)INT16_MAX >> shift) ? INT16_MAX : (int16_t)(v << shift);
}

static inline int16_t f_log2(uint32_t v) {
	if (v <= 1) {
		return 0;
	}
	unsigned lz = __builtin_clz(v);
	uint32_t frac = (v << (lz + 1)) >> 22;
	return (int16_t)(((31 - lz) << 10) | frac);
}

static inline void bucket_cleaner(struct pkt_ctx *c, struct flow *bucket, unsigned int size, uint32_t now) {
	for (unsigned int i = 0; i < size; i++) {
		struct flow *f = &bucket[i];

		if (f->state != FLOW_STATE_NEW && now - f->last_seen > 10000000) { // 10 seconds
			flow_free(c, f);
		}
	}
}

static void extract_features(const struct flow *f, int16_t in[NN_FEATURES]) {
	uint32_t n = f->total_pkts;
	uint32_t iat_mean = n > 1 ? f->iat_sum / (n - 1) : 0;

	in[0] = f_lin(n, 8);                    /* Number of Packets */
	in[1] = f_lin(f->t.src_port >> 1, 0);   /* Source Port */
	in[2] = f_lin(f->t.dst_port >> 1, 0);   /* Destination Port */
	in[3] = f_lin(f->total_bytes / n, 4);   /* Average Packet Size */
	in[4] = f_lin(f->pkt_min, 4);           /* Minimum Packet Size */
	in[5] = f_lin(f->pkt_max, 4);           /* Maximum Packet Size */
	in[6] = f_log2(f->total_bytes);         /* Total Bytes */
	in[7] = f_log2(f->iat_min);             /* IAT Min (µs) */
	in[8] = f_log2(f->iat_max);             /* IAT Max (µs) */
	in[9] = f_log2(iat_mean);               /* IAT Mean (µs) */
}

flexio_dev_event_handler_t pkt_handler;
__dpa_global__ void pkt_handler(uint64_t arg) {
	uint64_t start = __dpa_thread_cycles();
	struct pkt_ctx *c = (struct pkt_ctx *)arg;
	struct flexio_dev_cqe64 *ring = (struct flexio_dev_cqe64 *)c->cq_ring;

	while (flexio_dev_cqe_get_owner(&ring[c->cq_ci & Q_MASK]) == ((c->cq_ci >> LOG_Q_DEPTH) & 1)) {
		struct flexio_dev_cqe64 *cqe = &ring[c->cq_ci & Q_MASK];
		uint32_t idx = flexio_dev_cqe_get_wqe_counter(cqe) & Q_MASK;
		
		struct five_tuple t;
		parse_five_tuple((uint8_t *)(c->rx_bufs + idx * BUF_BSIZE), flexio_dev_cqe_get_byte_cnt(cqe), &t);
		
		struct flow *f = flow_update(c, &t, flow_hash(&t));
		
		uint32_t now = (uint32_t)__dpa_thread_time();

		if (f) {
			if (f->total_pkts > 0) {
				uint32_t iat = now - f->last_seen;

				f->iat_sum += iat;
				if (f->total_pkts == 1 || iat < f->iat_min) {
					f->iat_min = iat;
				}
				if (iat > f->iat_max) {
					f->iat_max = iat;
				}
			}
			uint32_t len = flexio_dev_cqe_get_byte_cnt(cqe);
			uint16_t len16 = len > 0xffff ? 0xffff : (uint16_t)len;

			if (len16 < f->pkt_min) {
				f->pkt_min = len16;
			}
			if (len16 > f->pkt_max) {
				f->pkt_max = len16;
			}
			f->last_seen = now;
			f->total_bytes += len;
			f->total_pkts++;
			f->rst_count += t.rst;
			f->psh_count += t.psh;
			f->fin_count += t.fin;

			if (f->total_pkts == NUM_PCKGS_BEFORE_CLASSIFICATION) {
				int16_t in[NN_FEATURES], out[NN_H4];

				extract_features(f, in);
				neural_network(in, out);
				int malicious = out[0] > NN_THRESHOLD;
				c->inferred++;
				c->malicious += malicious;
				if (malicious) {
					//__atomic_store_n(&f->state, FLOW_STATE_SUSPICIOUS, __ATOMIC_RELAXED); // other EUs read it concurrently
					flow_free(c, f);
				} else {
					flow_free(c, f);
				}
			}
		}

		c->count++;
		flexio_dev_dbr_cq_set_ci((uint32_t *)c->cq_dbr, ++c->cq_ci);
		flexio_dev_dbr_rq_inc_pi((uint32_t *)c->rq_dbr);

		uint64_t now2 = __dpa_thread_cycles();
		c->cycles += now2 - start;
		start = now2;
	}

	bucket_cleaner(c, (struct flow *)c->flows + c->sweep_index, FLOW_BUCKET_SIZE, (uint32_t)__dpa_thread_time());
	c->sweep_index = (c->sweep_index + FLOW_BUCKET_SIZE) & FLOW_MASK;

	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
	flexio_dev_cq_arm(c->cq_ci, c->cq_num);
	c->cycles += __dpa_thread_cycles() - start;
	flexio_dev_thread_reschedule();
}

__dpa_rpc__ uint64_t collect_stats(uint64_t ctxs, uint64_t num_eus, uint64_t out) {
	const uint64_t *ctx = (const uint64_t *)ctxs;
	struct stats *s = (struct stats *)out;
	uint64_t count = 0, cycles = 0, used = 0, collisions = 0, inferred = 0, malicious = 0;

	for (uint64_t eu = 0; eu < num_eus; eu++) {
		struct pkt_ctx *c = (struct pkt_ctx *)ctx[eu];

		count += c->count;
		cycles += c->cycles;
		collisions += c->collisions;
		used += c->used;
		inferred += c->inferred;
		malicious += c->malicious;
	}
	s->count = count;
	s->cycles = cycles;
	s->used = used;
	s->collisions = collisions;
	s->inferred = inferred;
	s->malicious = malicious;
	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
	return 0;
}

__dpa_rpc__ uint64_t age_flows(uint64_t ctxs, uint64_t num_eus) {
	const uint64_t *ctx = (const uint64_t *)ctxs;
	uint32_t now = (uint32_t)__dpa_thread_time();

	for (uint64_t eu = 0; eu < num_eus; eu++) {
		struct pkt_ctx *c = (struct pkt_ctx *)ctx[eu];
		struct flow *flows = (struct flow *)c->flows;

		for (unsigned int i = 0; i < (1u << LOG_FLOW_ENTRIES); i++) {
			struct flow *f = &flows[i];

			if (f->state != FLOW_STATE_NEW && now - f->last_seen > 10000000) { // 10 seconds
				flow_free(c, f);
			}
		}
	}
	return 0;
}
