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
	// only reached if the flow table is full, better yet we walked out of MAX_TABLE_WALK_DISTANCE
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

#define NN_SHIFT 7
#define NN_H0 10
#define NN_H1 16
#define NN_H2 16
#define NN_H3 8
#define NN_H4 1

static void layer(const int8_t *in, const int8_t *w, const int8_t *b, int8_t *out, int rows, int cols, int relu) {
    for (int r = 0; r < rows; r++) {
        int32_t acc = 0;
        for (int c = 0; c < cols; c++)
            acc += (int32_t)w[r * cols + c] * (int32_t)in[c];
        acc >>= NN_SHIFT;
        acc += b[r];
        if (relu && acc < 0)
            acc = 0;
        if (acc > 127)
            acc = 127;
        if (acc < -128)
            acc = -128;
        out[r] = (int8_t)acc;
    }
}

__dpa_global__ void small_neural_network(void) {
    int8_t w1[NN_H0 * NN_H1] = {27, -18, 38, -33, 1, 20, 14, 21, -13, 1, -27, -40, 21, -36, 10, 10, 9, 5, 20, -37, 13, 40, -24, 12, 40, -24, 26, 6, -12, 13, -20, -35, -29, -2, -23, 22, -3, 22, 20, -30, -25, -31, -10, -30, 22, -22, 21, 30, -36, -14, 23, -17, 27, 1, -4, 14, 8, 15, -15, -14, 31, -21, -15, 19, -12, 28, -33, 1, 10, -36, -23, 26, -22, -16, -18, -10, 14, -25, 34, -30, -22, -21, -11, -14, -7, 8, 0, 35, 14, 31, 17, -22, 40, 8, 28, -34, 38, 3, 29, 6, 10, 22, 2, 26, -12, 7, -28, 15, -28, 3, 34, -7, 25, -28, 6, 14, 16, -20, 11, 8, -38, -6, -3, 27, 24, 15, 25, -11, -6, -2, -12, 11, -9, 19, -35, 20, -7, 14, 2, 25, -24, -5, -33, -38, -22, 23, 35, -33, -4, -24, -29, 37, 9, -1, 38, -38, 28, 39, 15, -30};

    int8_t w2[NN_H1 * NN_H2] = {29, -22, -2, -31, 23, -7, -27, 15, 20, 27, -19, -21, 17, 16, 19, 29, 31, -11, 21, 22, -24, -9, -20, -11, -4, 2, 15, -23, -6, -27, 29, -8, 17, -23, 13, 1, 24, -15, -21, 9, -3, -19, -17, -23, -2, 14, 26, 23, 17, 16, 31, -8, 16, -8, 28, -14, -10, -17, 12, 6, -18, 10, 19, -27, -12, -7, 10, -9, -22, -14, -17, -16, 23, -14, 24, -25, 16, -26, -11, -26, -6, -2, -5, -26, 32, -5, -1, 13, -31, -28, 1, -15, -27, 17, -16, 15, -3, -6, -1, -26, 13, 29, -15, 29, 3, 8, 6, 5, -19, -6, -15, -14, -5, 14, 23, 23, 20, -6, 12, 18, 0, 9, -12, -9, -13, 1, -13, -3, 6, 30, 9, -2, 24, 14, -14, -10, -23, -11, 9, 23, 23, -26, -5, 3, 11, 20, 26, -16, -9, -12, 30, 15, -13, -19, 6, -11, 8, -7, 5, 26, 6, 8, -20, 12, 31, -7, -13, 15, 24, -22, -9, 10, 10, 32, 8, -1, 25, -11, -4, -28, 22, 9, -27, 12, -10, -16, -17, -16, -6, -3, -14, -6, 2, 7, -20, 14, -27, 21, 19, 24, -17, -11, -2, -7, -21, -10, -32, -19, 10, 22, -14, 23, 7, 14, -9, -1, 13, 0, -11, -20, -7, 10, -24, -28, 11, -12, -17, -13, -31, -14, 24, -23, -17, -17, 28, 10, 4, -24, -12, 31, 0, -20, -1, -32, 3, 2, -21, -3, 29, 21, 32, 18, -24, 5, -20, 0};

    int8_t w3[NN_H2 * NN_H3] = {-3, -6, 7, 24, 13, -31, 1, -24, 16, -12, 28, -30, 3, 22, 1, -13, 32, 28, 31, -21, -26, -7, 13, -10, 21, 29, -9, -11, -20, -20, 19, -32, 22, -23, 3, -9, 3, -20, 0, 0, -4, -27, -30, -27, 22, -3, -15, 17, 10, -22, -12, 13, 18, -32, 21, -31, 2, -13, 14, -25, 17, -14, 1, -17, 1, 26, 22, -25, -21, -21, 2, 3, 10, 4, 4, 30, 26, 17, -4, 17, 23, -5, 2, 21, -18, 1, 1, 7, -25, -26, 22, -8, -18, -4, -29, -31, -26, 0, -22, 2, 0, 30, -26, -23, 23, 31, -28, 28, 6, 29, 10, 11, 22, -27, 3, 5, -10, 30, 20, -22, -30, -24, -2, 27, -1, 23, 11, 4};

    int8_t w4[NN_H3 * NN_H4] = {36, 18, 26, -24, 32, 12, 14, -37};


    int8_t b1[NN_H1] = {28, 6, 27, -28, 1, 7, -20, 15, 38, 16, -3, 5, 1, 7, -12, 16};
    int8_t b2[NN_H2] = {-1, 20, -6, -8, -1, 10, 22, 22, 3, -8, -3, -6, -21, 16, 10, 29};
    int8_t b3[NN_H3] = {-5, -25, 6, -32, -15, -27, 3, -24};
    int8_t b4[NN_H4] = {-4};

    int8_t v0[NN_H0];
    int8_t v1[NN_H1];
    int8_t v2[NN_H2];
    int8_t v3[NN_H3];
    int8_t v4[NN_H4];
}