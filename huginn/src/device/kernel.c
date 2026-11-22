#include <libflexio-dev/flexio_dev_ver.h>
#define FLEXIO_DEV_VER_USED FLEXIO_DEV_VER(26, 4, 0)
#include <libflexio-dev/flexio_dev.h>
#include <libflexio-dev/flexio_dev_queue_access.h>
#include <dpaintrin.h>
#include <stddef.h>
#include "../common.h"
#include "../model.h"

#define NN_FEATURES 14
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

static void flow_free(struct pkt_ctx *c, struct flow *f) {
	c->used--;
	f->state = FLOW_STATE_NEW;
}

static inline void sq_poll(struct pkt_ctx *c) {
	struct flexio_dev_cqe64 *ring = (struct flexio_dev_cqe64 *)c->sq_cq_ring;
	uint32_t n = 0;

	while (flexio_dev_cqe_get_owner(&ring[c->sq_cq_ci & SQ_MASK]) == ((c->sq_cq_ci >> LOG_SQ_DEPTH) & 1)) {
		struct flexio_dev_cqe64 *cqe = &ring[c->sq_cq_ci & SQ_MASK];
		uint16_t wc = flexio_dev_cqe_get_wqe_counter(cqe);

		if (flexio_dev_cqe_get_opcode(cqe) >= 0xd) {
			c->sq_errors++;
		}
		c->sq_ci += (uint16_t)(wc + 1 - (uint16_t)c->sq_ci);
		c->mal_acked = c->sq_rec_end[wc & SQ_MASK];
		c->sq_cq_ci++;
		n++;
	}
	if (n) {
		flexio_dev_dbr_cq_set_ci((uint32_t *)c->sq_cq_dbr, c->sq_cq_ci);
	}
}

static inline void sq_post(struct pkt_ctx *c, uint64_t from, uint32_t n) {
	uint64_t end = from + n;
	uint32_t off = (uint32_t)(from & MAL_RING_MASK) * sizeof(struct malicious_flow_record);
	union flexio_dev_sqe_seg *s = (union flexio_dev_sqe_seg *)c->sq_ring + (c->sq_pi & SQ_MASK) * 4;
	int signal = (c->sq_pi & (SIG_EVERY - 1)) == SIG_EVERY - 1 || end - c->mal_acked >= MAL_RING_SIZE / 2;

	flexio_dev_swqe_seg_ctrl_set(&s[0], c->sq_pi, c->qp_num,
		signal ? FLEXIO_CTRL_SEG_CE_CQE_ALWAYS : FLEXIO_CTRL_SEG_CE_CQE_ON_CQE_ERROR,
		FLEXIO_CTRL_SEG_TYPE_RDMA_WRITE);
	flexio_dev_swqe_seg_rdma_set(&s[1], c->mal_rkey, c->mal_raddr + off);
	flexio_dev_swqe_seg_mem_ptr_data_set(&s[2], n * sizeof(struct malicious_flow_record), c->mal_lkey, c->mal_stage + off);
	c->sq_rec_end[c->sq_pi & SQ_MASK] = end;
	c->sq_pi++;
}

static void mal_flush(struct pkt_ctx *c) {
	sq_poll(c);

	uint64_t from = c->mal_posted, to = c->mal_pi;
	if (from == to || c->sq_pi - c->sq_ci > SQ_DEPTH - 2) {
		return;
	}

	uint32_t room = MAL_RING_SIZE - (uint32_t)(from & MAL_RING_MASK);
	if (to - from > room) {
		sq_post(c, from, room);
		sq_post(c, from + room, (uint32_t)(to - from - room));
	} else {
		sq_post(c, from, (uint32_t)(to - from));
	}
	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
	flexio_dev_qp_sq_ring_db((uint16_t)c->sq_pi, c->qp_num);
	c->mal_posted = to;
}

static void mal_report(struct pkt_ctx *c, const struct flow *f, int16_t score) {
	if (c->mal_pi - c->mal_acked >= MAL_RING_SIZE) {
		sq_poll(c);
		if (c->mal_pi - c->mal_acked >= MAL_RING_SIZE) {
			c->mal_dropped++;
			return;
		}
	}

	struct malicious_flow_record *r = (struct malicious_flow_record *)c->mal_stage + (c->mal_pi & MAL_RING_MASK);
	__builtin_memcpy(&r->f, f, sizeof(*f));
	r->score = score;
	r->eu = (uint16_t)c->eu;
	r->ts = (uint32_t)__dpa_thread_time();
	r->seq = (uint32_t)(c->mal_pi + 1);
	c->mal_pi++;
}

static void extract_features(const struct flow *f, int16_t in[NN_FEATURES]) {
	uint32_t n = f->total_pkts;
	uint32_t iat_mean = n > 1 ? f->iat_sum / (n - 1) : 0;

	in[0] = f_lin(n, 8);                   
	in[1] = f_lin(f->t.src_port >> 1, 0);   
	in[2] = f_lin(f->t.dst_port >> 1, 0);   
	in[3] = f_lin(f->total_bytes / n, 4);   
	in[4] = f_lin(f->pkt_min, 4);           
	in[5] = f_lin(f->pkt_max, 4);           
	in[6] = f_log2(f->total_bytes);        
	in[7] = f_log2(f->iat_min);             
	in[8] = f_log2(f->iat_max);             
	in[9] = f_log2(iat_mean);               
	in[10] = f_lin(f->rst_count, 8);          
	in[11] = f_lin(f->psh_count, 8);          
	in[12] = f_lin(f->fin_count, 8);       
	in[13] = f_lin(f->urg_count, 8);
}

int infer_flow(struct pkt_ctx *c, struct flow *f) {
	int16_t in[NN_FEATURES], out[NN_H4];

	extract_features(f, in);
	neural_network(in, out);
	int malicious = out[0] > NN_THRESHOLD;
	c->inferred++;
	c->malicious += malicious;
	if (malicious) {
		mal_report(c, f, out[0]);
		//__atomic_store_n(&f->state, FLOW_STATE_SUSPICIOUS, __ATOMIC_RELAXED); // other EUs read it concurrently
		flow_free(c, f);
	} else {
		flow_free(c, f);
	}
	return malicious;
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
		t->rst = (ip[ip_hdr_len + 13] >> 2) & 1;
		t->psh = (ip[ip_hdr_len + 13] >> 3) & 1;
		t->fin = (ip[ip_hdr_len + 13] >> 0) & 1;
		t->urg = (ip[ip_hdr_len + 13] >> 5) & 1;
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
			int malicious = infer_flow(c, f);
			if(malicious) {
				flow_free(c, f);
			}
			else {
				flow_free(c, f);
			}
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
		f->urg_count = 0;
		f->pkt_min = 0xffff;
		f->pkt_max = 0;
		f->suspicion_score = 0;
		c->used++;
		return f;
	}
	c->collisions++;
	return NULL;
}



static inline void bucket_cleaner(struct pkt_ctx *c, struct flow *bucket, unsigned int size, uint32_t now) {
	for (unsigned int i = 0; i < size; i++) {
		struct flow *f = &bucket[i];

		if (f->state != FLOW_STATE_NEW && now - f->last_seen > 10000000) { // 10 seconds
			int malicious = infer_flow(c, f);

			if (malicious) {
				flow_free(c, f);
			}
			else {
				flow_free(c, f);
			}
		}
	}
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
			f->urg_count += t.urg;

			if (f->total_pkts == NUM_PCKGS_BEFORE_CLASSIFICATION) {
				infer_flow(c, f);
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

	mal_flush(c);

	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
	flexio_dev_cq_arm(c->cq_ci, c->cq_num);
	c->cycles += __dpa_thread_cycles() - start;
	flexio_dev_thread_reschedule();
}

__dpa_rpc__ uint64_t collect_stats(uint64_t ctxs, uint64_t num_eus, uint64_t out) {
	const uint64_t *ctx = (const uint64_t *)ctxs;
	struct stats *s = (struct stats *)out;
	uint64_t count = 0, cycles = 0, used = 0, collisions = 0, inferred = 0, malicious = 0, mal_dropped = 0, sq_errors = 0;

	for (uint64_t eu = 0; eu < num_eus; eu++) {
		struct pkt_ctx *c = (struct pkt_ctx *)ctx[eu];

		count += c->count;
		cycles += c->cycles;
		collisions += c->collisions;
		used += c->used;
		inferred += c->inferred;
		malicious += c->malicious;
		mal_dropped += c->mal_dropped;
		sq_errors += c->sq_errors;
	}
	s->count = count;
	s->cycles = cycles;
	s->used = used;
	s->collisions = collisions;
	s->inferred = inferred;
	s->malicious = malicious;
	s->mal_dropped = mal_dropped;
	s->sq_errors = sq_errors;
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
