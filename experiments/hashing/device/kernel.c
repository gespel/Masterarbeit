#include <libflexio-dev/flexio_dev_ver.h>             /* FLEXIO_DEV_VER() macro */
#define FLEXIO_DEV_VER_USED FLEXIO_DEV_VER(26, 4, 0)    /* pin the device API version we compile against */
#include <libflexio-dev/flexio_dev.h>                 /* core DPA API: threads, prints, event handler types */
#include <libflexio-dev/flexio_dev_queue_access.h>    /* CQE accessors, doorbell/arm helpers, be16_to_cpu() etc. */
#include <dpaintrin.h>                                /* DPA intrinsics, e.g. __dpa_thread_fence(), __dpa_thread_cycles() */
#include "../common.h"                                /* struct pkt_ctx and flow_hash() shared with the host */

#define Q_MASK ((1u << LOG_Q_DEPTH) - 1)              /* turns a free-running index into a ring slot (depth is a power of two) */

#define ETH_HDR_LEN    14                             /* dst MAC (6) + src MAC (6) + EtherType (2) */
#define ETH_TYPE       12                             /* offset of EtherType in the Ethernet header */
#define ETHERTYPE_IPV4 0x0800                         /* EtherType value for IPv4 */

#define IP_MIN_HDR_LEN 20                             /* IPv4 header without options */
#define IP_FRAG        6                              /* offsets in the IPv4 header */
#define IP_PROTO       9
#define IP_SRC         12
#define IP_DST         16
#define IP_FRAG_OFFSET 0x1fff                         /* fragment offset bits of the flags/offset field */

#define IPPROTO_TCP    6
#define IPPROTO_UDP    17

#define L4_SRC_PORT    0                              /* offsets in the TCP and UDP header (same for both) */
#define L4_DST_PORT    2

/* Read a 2/4 byte field from the packet and convert it from network to host byte order. */
static inline uint16_t read_u16(const uint8_t *p)
{
	uint16_t v;
	__builtin_memcpy(&v, p, sizeof(v));               /* memcpy: safe even if p is not aligned */
	return be16_to_cpu(v);
}

static inline uint32_t read_u32(const uint8_t *p)
{
	uint32_t v;
	__builtin_memcpy(&v, p, sizeof(v));
	return be32_to_cpu(v);
}

/* Fill t from an Ethernet frame. Returns 0 if the frame is not IPv4 or too short for the IP header. */
static int parse_five_tuple(const uint8_t *pkt, uint32_t len, struct five_tuple *t)
{
	if (len < ETH_HDR_LEN + IP_MIN_HDR_LEN || read_u16(pkt + ETH_TYPE) != ETHERTYPE_IPV4)
		return 0;

	const uint8_t *ip = pkt + ETH_HDR_LEN;            /* IPv4 header starts right after Ethernet */
	uint32_t ip_hdr_len = (ip[0] & 0xf) * 4;          /* lower half of byte 0 = header length in 4-byte units */
	const uint8_t *l4 = ip + ip_hdr_len;              /* TCP/UDP header follows the IP header */

	t->proto    = ip[IP_PROTO];                       /* 6 = TCP, 17 = UDP */
	t->src_ip   = read_u32(ip + IP_SRC);
	t->dst_ip   = read_u32(ip + IP_DST);
	t->src_port = 0;
	t->dst_port = 0;

	/* Ports only exist for TCP/UDP, only in the first fragment, and only if the L4 header was received. */
	if ((t->proto == IPPROTO_TCP || t->proto == IPPROTO_UDP) &&
	    !(read_u16(ip + IP_FRAG) & IP_FRAG_OFFSET) &&
	    ip_hdr_len >= IP_MIN_HDR_LEN &&
	    len >= ETH_HDR_LEN + ip_hdr_len + 4) {
		t->src_port = read_u16(l4 + L4_SRC_PORT);
		t->dst_port = read_u16(l4 + L4_DST_PORT);
	}
	return 1;
}

/* Runs whenever a CQE lands on the armed RQ CQ. */
flexio_dev_event_handler_t pkt_handler;               /* declaration with the type the FlexIO tooling expects */
__dpa_global__ void pkt_handler(uint64_t arg)         /* entry point, arg = DPA address passed to flexio_event_handler_run() */
{
	struct pkt_ctx *c = (struct pkt_ctx *)arg;                            /* our state in DPA heap memory */
	struct flexio_dev_cqe64 *ring = (struct flexio_dev_cqe64 *)c->cq_ring; /* CQ ring: Q_DEPTH CQEs of 64 bytes */

	/* A CQE is new if its owner bit matches the current wrap-around parity. */
	while (flexio_dev_cqe_get_owner(&ring[c->cq_ci & Q_MASK]) == ((c->cq_ci >> LOG_Q_DEPTH) & 1)) { /* one iteration = one packet */
		struct flexio_dev_cqe64 *cqe = &ring[c->cq_ci & Q_MASK];      /* the CQE we are processing now */
		uint32_t idx = flexio_dev_cqe_get_wqe_counter(cqe) & Q_MASK;  /* which RQ entry (= RX buffer) the NIC filled */
		uint32_t len = flexio_dev_cqe_get_byte_cnt(cqe);              /* packet length in bytes */
		uint8_t *pkt = (uint8_t *)(c->rx_bufs + idx * BUF_BSIZE);     /* start of the packet (Ethernet header) */
		struct five_tuple t;
		
		uint64_t start = __dpa_thread_cycles();
		if (parse_five_tuple(pkt, len, &t)) {
			//uint64_t start = __dpa_thread_cycles();
			uint32_t hash = flow_hash(&t);
			uint64_t cycles = __dpa_thread_cycles() - start;
			c->hash_cycles += cycles;
			c->last_hash = hash;
			if (c->hashed < LOG_ENTRIES)                              /* keep hash and cycles for the host, cheaper than printing */
				((uint64_t *)c->pkt_log)[c->hashed] = (cycles << 32) | hash;
			c->hashed++;

			/*flexio_dev_print("%u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, proto=%u, len=%u, hash=0x%08x, cycles=%lu\n",
				(t.src_ip >> 24) & 0xff, (t.src_ip >> 16) & 0xff, (t.src_ip >> 8) & 0xff, t.src_ip & 0xff, t.src_port,
				(t.dst_ip >> 24) & 0xff, (t.dst_ip >> 16) & 0xff, (t.dst_ip >> 8) & 0xff, t.dst_ip & 0xff, t.dst_port,
				t.proto, len, hash, cycles);*/
		}

		c->count++;                                                   /* count every packet */
		flexio_dev_dbr_cq_set_ci((uint32_t *)c->cq_dbr, ++c->cq_ci);  /* consume the CQE and tell the NIC the slot is free */
		flexio_dev_dbr_rq_inc_pi((uint32_t *)c->rq_dbr); /* recycle the RX buffer; only after parsing, NIC may overwrite it now */
	}

	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);  /* make the doorbell writes visible before arming */
	flexio_dev_cq_arm(c->cq_ci, c->cq_num);              /* request the next event for CQEs from cq_ci on */
	flexio_dev_thread_reschedule();                      /* give the DPA core back, we are woken up by the next event */
}

__dpa_rpc__ uint64_t get_count(uint64_t arg)          /* RPCs the host calls via flexio_process_call(), arg = ctx address */
{
	return ((struct pkt_ctx *)arg)->count;
}

__dpa_rpc__ uint64_t get_hashed(uint64_t arg)
{
	return ((struct pkt_ctx *)arg)->hashed;
}

__dpa_rpc__ uint64_t get_hash_cycles(uint64_t arg)
{
	return ((struct pkt_ctx *)arg)->hash_cycles;
}

/* Self-test: hash a tuple given by the host, so the host can compare against its own flow_hash(). */
__dpa_rpc__ uint64_t hash_tuple(uint64_t src_ip, uint64_t dst_ip, uint64_t ports, uint64_t proto)
{
	struct five_tuple t = {
		.src_ip = src_ip,
		.dst_ip = dst_ip,
		.src_port = ports >> 16,
		.dst_port = ports & 0xffff,
		.proto = proto,
	};
	return flow_hash(&t);
}

__dpa_rpc__ uint64_t read_u64(uint64_t addr)          /* lets the host read back DPA heap memory */
{
	return *(uint64_t *)addr;
}
