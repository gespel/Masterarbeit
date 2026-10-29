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

static int parse_five_tuple(const uint8_t *pkt, uint32_t len, struct five_tuple *t) {
	const uint8_t *ip = pkt + ETH_HDR_LEN;
	uint32_t ip_hdr_len = (ip[0] & 0xf) * 4;
	const uint8_t *l4 = ip + ip_hdr_len;

	t->proto    = ip[IP_PROTO];
	t->src_ip   = read_u32(ip + IP_SRC);
	t->dst_ip   = read_u32(ip + IP_DST);
	t->src_port = 0;
	t->dst_port = 0;

	if ((t->proto == IPPROTO_TCP || t->proto == IPPROTO_UDP) && !(read_u16(ip + IP_FRAG) & IP_FRAG_OFFSET) && ip_hdr_len >= IP_MIN_HDR_LEN && len >= ETH_HDR_LEN + ip_hdr_len + 4) {
		t->src_port = read_u16(l4 + L4_SRC_PORT);
		t->dst_port = read_u16(l4 + L4_DST_PORT);
	}
	return 1;
}

flexio_dev_event_handler_t pkt_handler;
__dpa_global__ void pkt_handler(uint64_t arg) {
	struct pkt_ctx *c = (struct pkt_ctx *)arg;
	struct flexio_dev_cqe64 *ring = (struct flexio_dev_cqe64 *)c->cq_ring;

	while (flexio_dev_cqe_get_owner(&ring[c->cq_ci & Q_MASK]) == ((c->cq_ci >> LOG_Q_DEPTH) & 1)) {
		struct flexio_dev_cqe64 *cqe = &ring[c->cq_ci & Q_MASK];
		uint32_t idx = flexio_dev_cqe_get_wqe_counter(cqe) & Q_MASK;
		uint32_t len = flexio_dev_cqe_get_byte_cnt(cqe);
		uint8_t *pkt = (uint8_t *)(c->rx_bufs + idx * BUF_BSIZE);
		struct five_tuple t;
		
		uint64_t start = __dpa_thread_cycles();
		if (parse_five_tuple(pkt, len, &t)) {
			//uint64_t start = __dpa_thread_cycles();
			uint32_t hash = flow_hash(&t);
			((struct five_tuple *)c->flows)[hash & FLOW_MASK] = t;
			uint64_t cycles = __dpa_thread_cycles() - start;
			/*flexio_dev_print("hash=0x%08x, src=%u.%u.%u.%u:%u, dst=%u.%u.%u.%u:%u, proto=%u\n",
				hash,
				(t.src_ip >> 24) & 0xff, (t.src_ip >> 16) & 0xff, (t.src_ip >> 8) & 0xff, t.src_ip & 0xff, t.src_port,
				(t.dst_ip >> 24) & 0xff, (t.dst_ip >> 16) & 0xff, (t.dst_ip >> 8) & 0xff, t.dst_ip & 0xff, t.dst_port,
				t.proto);*/

			c->hash_cycles += cycles;
			c->last_hash = hash;
			c->hashed++;

			/*flexio_dev_print("%u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, proto=%u, len=%u, hash=0x%08x, cycles=%lu\n",
				(t.src_ip >> 24) & 0xff, (t.src_ip >> 16) & 0xff, (t.src_ip >> 8) & 0xff, t.src_ip & 0xff, t.src_port,
				(t.dst_ip >> 24) & 0xff, (t.dst_ip >> 16) & 0xff, (t.dst_ip >> 8) & 0xff, t.dst_ip & 0xff, t.dst_port,
				t.proto, len, hash, cycles);*/
		}

		c->count++;
		flexio_dev_dbr_cq_set_ci((uint32_t *)c->cq_dbr, ++c->cq_ci);
		flexio_dev_dbr_rq_inc_pi((uint32_t *)c->rq_dbr);
	}

	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
	flexio_dev_cq_arm(c->cq_ci, c->cq_num);
	flexio_dev_thread_reschedule();
}

__dpa_rpc__ uint64_t get_count(uint64_t arg) {
	return ((struct pkt_ctx *)arg)->count;
}

__dpa_rpc__ uint64_t get_hashed(uint64_t arg) {
	return ((struct pkt_ctx *)arg)->hashed;
}

__dpa_rpc__ uint64_t get_hash_cycles(uint64_t arg) {
	return ((struct pkt_ctx *)arg)->hash_cycles;
}

__dpa_rpc__ uint64_t read_u64(uint64_t addr) {
	return *(uint64_t *)addr;
}

__dpa_rpc__ uint64_t dump_flows(uint64_t arg) {
	struct pkt_ctx *c = (struct pkt_ctx *)arg;
	struct five_tuple *flows = (struct five_tuple *)c->flows;
	uint64_t num_flows = 0;

	for (uint32_t i = 0; i < (1u << LOG_FLOW_ENTRIES); i++) {
		if (flows[i].proto != 0) {
			/*flexio_dev_print("flow[%u]: %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, proto=%u\n",
				i,
				(flows[i].src_ip >> 24) & 0xff, (flows[i].src_ip >> 16) & 0xff, (flows[i].src_ip >> 8) & 0xff, flows[i].src_ip & 0xff, flows[i].src_port,
				(flows[i].dst_ip >> 24) & 0xff, (flows[i].dst_ip >> 16) & 0xff, (flows[i].dst_ip >> 8) & 0xff, flows[i].dst_ip & 0xff, flows[i].dst_port,
				flows[i].proto);*/
			num_flows++;
		}
	}
	c->num_flows = num_flows;
	return num_flows;
}