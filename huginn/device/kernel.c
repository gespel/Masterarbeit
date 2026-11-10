#include <libflexio-dev/flexio_dev_ver.h>
#define FLEXIO_DEV_VER_USED FLEXIO_DEV_VER(26, 4, 0)
#include <libflexio-dev/flexio_dev.h>
#include <libflexio-dev/flexio_dev_queue_access.h>
#include <dpaintrin.h>
#include <stddef.h>
#include "../common.h"

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

static int flow_lock(struct flow *f) {
	if (f->state != FLOW_STATE_NEW) {
		return 0;
	}
	if (__atomic_exchange_n(&f->state, FLOW_STATE_KNOWN, __ATOMIC_ACQUIRE) == FLOW_STATE_NEW) {
		return 1;
	}
	return 0;
}

static int tuple_eq(const struct five_tuple *a, const struct five_tuple *b) {
	return a->src_ip == b->src_ip && a->dst_ip == b->dst_ip && a->src_port == b->src_port && a->dst_port == b->dst_port && a->proto == b->proto;
}

/* Set-associative lookup: the hash picks a bucket of FLOW_WAYS adjacent slots and the flow lives in one of them or nowhere.
 * Freed slots can sit in front of the flow, so search all ways before claiming a free one; free slots still hold their old
 * tuple and must not match. Returns NULL if the bucket is full of other flows or another EU took the free slot first. */
static struct flow *flow_update(struct pkt_ctx *c, const struct five_tuple *t, uint32_t hash) {
	int index = hash & FLOW_MASK & ~(FLOW_WAYS - 1);
	struct flow *bucket = &((struct flow *)c->flows)[index];
	struct flow *free_slot = NULL;

	for (unsigned int i = 0; i < FLOW_WAYS; i++) {
		struct flow *f = &bucket[i];

		if (f->state == FLOW_STATE_NEW) {
			if (free_slot == NULL) {
				free_slot = f;
			}
		} else if (f->hash == hash && tuple_eq(&f->t, t)) {
			return f; // return a flow that is known
		}
	}
	if (free_slot != NULL && flow_lock(free_slot) == 1) {
		struct flow *f = free_slot;
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
		f->suspicion_score = 0;
		c->used++;
		return f;
	}
	c->collisions++;
	return NULL;
}

static void flow_free(struct pkt_ctx *c, struct flow *f) {
	f->hash ^= 1; // flip a bit to make the flow's hash different from its tuple, so other EUs won't match it anymore
	c->used--;
	__atomic_store_n(&f->state, FLOW_STATE_NEW, __ATOMIC_RELEASE);
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
			f->last_seen = now;
			f->total_bytes += flexio_dev_cqe_get_byte_cnt(cqe);
			f->total_pkts++;

			// a flow passes this count only once: benign ones restart from 0 in a new slot, malicious ones keep counting
			if (f->total_pkts >= NUM_PCKGS_BEFORE_CLASSIFICATION) {
				int malicious = 0;
				// TODO: inference
				c->inferred++;
				if (malicious) {
					__atomic_store_n(&f->state, FLOW_STATE_SUSPICIOUS, __ATOMIC_RELAXED); // other EUs read it concurrently
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

	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
	flexio_dev_cq_arm(c->cq_ci, c->cq_num);
	c->cycles += __dpa_thread_cycles() - start;
	flexio_dev_thread_reschedule();
}

__dpa_rpc__ uint64_t collect_stats(uint64_t ctxs, uint64_t num_eus, uint64_t out) {
	const uint64_t *ctx = (const uint64_t *)ctxs;
	struct stats *s = (struct stats *)out;
	uint64_t count = 0, cycles = 0, used = 0, collisions = 0, inferred = 0;

	for (uint64_t eu = 0; eu < num_eus; eu++) {
		struct pkt_ctx *c = (struct pkt_ctx *)ctx[eu];

		count += c->count;
		cycles += c->cycles;
		collisions += c->collisions;
		used += c->used;
		inferred += c->inferred;
	}
	s->count = count;
	s->cycles = cycles;
	s->used = used;
	s->collisions = collisions;
	s->inferred = inferred;
	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
	return 0;
}
