/* Shared host/DPA state and the flow hash, compiled for both sides. */
#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>

#define LOG_Q_DEPTH 7
#define BUF_BSIZE   2048

#define HASH_SEED   0x9e3779b9u
#define LOG_ENTRIES (1u << 17)

struct pkt_ctx {
	uint64_t cq_ring, cq_dbr, rq_dbr; /* DPA addresses */
	uint64_t rx_bufs;                 /* DPA address of the RX buffers */
	uint32_t cq_num;                  /* CQ number, needed to arm the CQ */
	uint32_t cq_ci;                   /* CQ consumer index */
	uint64_t count;                   /* received packets */
	uint64_t hashed;                  /* packets with a 5-tuple that were hashed (IPv4) */
	uint64_t hash_cycles;             /* DPA cycles spent inside flow_hash(), summed over all hashed packets */
	uint32_t last_hash;               /* hash of the most recent packet */
	uint64_t pkt_log;                 /* DPA address of the per-packet log, LOG_ENTRIES x uint64_t */
};

/* Result of one hash_bench() run, written by the DPA into DPA heap memory. */
struct bench_res {
	uint64_t cycles;                  /* DPA cycles for all n hashes */
	uint64_t us;                      /* wall time for all n hashes (__dpa_thread_time() ticks at 1 MHz) */
	uint64_t sink;                    /* last hash, keeps the compiler from dropping the loop */
};

/* 5-tuple in host byte order; ports are 0 for non-TCP/UDP packets and non-first fragments. */
struct five_tuple {
	uint32_t src_ip, dst_ip;
	uint16_t src_port, dst_port;
	uint8_t  proto;
};

/* Bob Jenkins' lookup3 final mix as used by jhash_3words() in the Linux kernel.
  Only add/xor, no multiply */
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

static inline uint32_t flow_hash(const struct five_tuple *t)
{
	return jhash_3words(t->src_ip, t->dst_ip, ((uint32_t)t->src_port << 16) | t->dst_port,
			    HASH_SEED ^ t->proto);
}

#endif /* COMMON_H */
