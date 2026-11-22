/* Shared host/DPA state and the flow hash, compiled for both sides. */
#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>

#define LOG_Q_DEPTH    7
#define Q_MASK         ((1u << LOG_Q_DEPTH) - 1)
#define BUF_BSIZE      2048
#define ETH_HDR_LEN    14
#define IP_FRAG        6
#define IP_PROTO       9
#define IP_SRC         12
#define IP_DST         16
#define IP_FRAG_OFFSET 0x1fff
#define IPPROTO_TCP    6
#define IPPROTO_UDP    17
#define HASH_SEED      0x9e3779b9u
#define LOG_FLOW_ENTRIES 15 // per EU, every EU has its own table
#define FLOW_MASK      ((1u << LOG_FLOW_ENTRIES) - 1)
#define NUM_FLOW_GENERATIONS 4 // number of generations to keep in the flow table

#define FLOW_BUCKET_SIZE 8
#define NUM_PCKGS_BEFORE_CLASSIFICATION 8

#define LOG_MAL_RING   10
#define MAL_RING_SIZE  (1u << LOG_MAL_RING)
#define MAL_RING_MASK  (MAL_RING_SIZE - 1)
#define LOG_SQ_DEPTH   6
#define SQ_DEPTH       (1u << LOG_SQ_DEPTH)
#define SQ_MASK        (SQ_DEPTH - 1)
#define SIG_EVERY      16

typedef enum FlowState {
	FLOW_STATE_NEW = 0,
	FLOW_STATE_KNOWN = 1,
	FLOW_STATE_SUSPICIOUS = 2,
} FlowState;

struct pkt_ctx {
	uint64_t cq_ring, cq_dbr, rq_dbr;
	uint64_t rx_bufs;
	uint64_t flows;
	uint64_t flow_generations[NUM_FLOW_GENERATIONS];
	uint32_t cq_num;
	uint32_t cq_ci;
	uint64_t count;
	uint64_t cycles;
	uint64_t collisions;
	uint64_t used;
	uint64_t inferred;
	uint64_t malicious;
	uint64_t sweep_index;
	uint32_t eu;
	uint32_t qp_num;
	uint64_t sq_ring;
	uint64_t sq_cq_ring;
	uint64_t sq_cq_dbr;
	uint32_t sq_pi;
	uint32_t sq_ci;
	uint32_t sq_cq_ci;
	uint32_t mal_lkey;
	uint32_t mal_rkey;
	uint64_t mal_raddr;
	uint64_t mal_stage;
	uint64_t mal_pi;
	uint64_t mal_posted;
	uint64_t mal_acked;
	uint64_t mal_dropped;
	uint64_t sq_errors;
	uint64_t sq_rec_end[SQ_DEPTH];
};

struct stats {
	uint64_t count;
	uint64_t cycles;
	uint64_t used;
	uint64_t collisions;
	uint64_t inferred;
	uint64_t malicious;
	uint64_t mal_dropped;
	uint64_t sq_errors;
};

struct five_tuple {
	uint32_t src_ip, dst_ip;
	uint16_t src_port, dst_port;
	uint8_t  proto;
	uint8_t rst;
	uint8_t psh;
	uint8_t fin;
	uint8_t urg;
};

struct flow {
	struct five_tuple t;
	uint32_t hash;
	FlowState state;

	uint32_t total_bytes;
	uint32_t total_pkts;
	uint32_t iat_min;
	uint32_t iat_max;
	uint32_t iat_sum;
	uint32_t last_seen;
	uint32_t rst_count;
	uint32_t psh_count;
	uint32_t fin_count;
	uint32_t urg_count;

	uint16_t pkt_min;
	uint16_t pkt_max;
	uint16_t suspicion_score;
};

struct malicious_flow_record {
	struct flow f;
	int16_t score;
	uint16_t eu;
	uint32_t ts;
	uint8_t _pad[128 - sizeof(struct flow) - 12];
	uint32_t seq;
} __attribute__((aligned(64)));

_Static_assert(sizeof(struct flow) == 76, "struct flow layout differs between host and DPA");
_Static_assert(sizeof(struct malicious_flow_record) == 128, "struct malicious_flow_record must be 128 bytes");

// Bob Jenkins' lookup3 final mix as used by jhash_3words() in the Linux kernel.
static inline uint32_t rol32(uint32_t w, unsigned s)
{
	return (w << s) | (w >> ((-s) & 31));
}

static inline uint32_t jhash_3words(uint32_t a, uint32_t b, uint32_t c, uint32_t initval)
{
	initval += 0xdeadbeef + (3 << 2);
	a += initval;
	b += initval;
	c += initval;
	c ^= b; c -= rol32(b, 14);
	a ^= c; a -= rol32(c, 11);
	b ^= a; b -= rol32(a, 25);
	c ^= b; c -= rol32(b, 16);
	a ^= c; a -= rol32(c, 4);
	b ^= a; b -= rol32(a, 14);
	c ^= b; c -= rol32(b, 24);
	return c;
}

static inline uint32_t flow_hash(const struct five_tuple *t) {
	return jhash_3words(t->src_ip, t->dst_ip, ((uint32_t)t->src_port << 16) | t->dst_port, HASH_SEED ^ t->proto);
}

#endif /* COMMON_H */
