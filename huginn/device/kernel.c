#include <libflexio-dev/flexio_dev_ver.h>
#define FLEXIO_DEV_VER_USED FLEXIO_DEV_VER(26, 4, 0)
#include <libflexio-dev/flexio_dev.h>
#include <libflexio-dev/flexio_dev_queue_access.h>
#include <dpaintrin.h>
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
}

static void flow_update(struct pkt_ctx *c, const struct five_tuple *t, uint32_t hash) {
	struct flow *flows = (struct flow *)c->flows;

	for (uint32_t i = 0; i < MAX_TABLE_WALK_DISTANCE; i++) {
		struct flow *f = &flows[(hash + i) & FLOW_MASK];

		if (f->state == FLOW_STATE_NEW) {
			f->t = *t;
			f->hash = hash;
			f->state = FLOW_STATE_KNOWN;
			f->suspicion_score = 0;
			return;
		}
		if (f->hash == hash && f->t.src_ip == t->src_ip && f->t.dst_ip == t->dst_ip && f->t.src_port == t->src_port && f->t.dst_port == t->dst_port && f->t.proto == t->proto) {
			return; // known flow, nothing to do
		}
	}
	// only reached if the flow table is full
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
		flow_update(c, &t, flow_hash(&t));
		c->count++;
		flexio_dev_dbr_cq_set_ci((uint32_t *)c->cq_dbr, ++c->cq_ci);
		flexio_dev_dbr_rq_inc_pi((uint32_t *)c->rq_dbr);

		uint64_t now = __dpa_thread_cycles(); /* under full load the loop never ends, so account per packet */
		c->cycles += now - start;
		start = now;
	}

	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
	flexio_dev_cq_arm(c->cq_ci, c->cq_num);
	c->cycles += __dpa_thread_cycles() - start;
	flexio_dev_thread_reschedule();
}

__dpa_rpc__ uint64_t read_u64(uint64_t addr) {
	return *(uint64_t *)addr;
}

__dpa_rpc__ uint64_t flow_table_fill(uint64_t addr) {
	struct flow *flows = (struct flow *)addr;
	uint64_t used = 0;

	for (uint32_t i = 0; i <= FLOW_MASK; i++) {
		if (flows[i].state != FLOW_STATE_NEW)
			used++;
	}
	return used;
}
