#include <libflexio-dev/flexio_dev_ver.h>             /* FLEXIO_DEV_VER() macro */
#define FLEXIO_DEV_VER_USED FLEXIO_DEV_VER(26, 4, 0)    /* pin the device API version we compile against */
#include <libflexio-dev/flexio_dev.h>                 /* core DPA API: threads, prints, event handler types */
#include <libflexio-dev/flexio_dev_queue_access.h>    /* CQE accessors, doorbell/arm helpers, be16_to_cpu() etc. */
#include <dpaintrin.h>                                /* DPA intrinsics, e.g. __dpa_thread_fence() */
#include "../common.h"                                /* struct pkt_ctx shared with the host */

#define Q_MASK ((1u << LOG_Q_DEPTH) - 1)              /* turns a free-running index into a ring slot (depth is a power of two) */

#define ETH_HDR_LEN    14                             /* dst MAC (6) + src MAC (6) + EtherType (2) */
#define ETH_TYPE       12                             /* offset of EtherType in the Ethernet header */
#define ETHERTYPE_IPV4 0x0800                         /* EtherType value for IPv4 */

#define IP_PROTO       9                              /* offsets in the IPv4 header */
#define IP_SRC         12
#define IP_DST         16

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

		if (len >= ETH_HDR_LEN) {                                     /* only read the header if it is fully there */
			uint16_t ethertype = read_u16(pkt + ETH_TYPE);            /* EtherType follows the two MAC addresses */
			if (ethertype == ETHERTYPE_IPV4) {                        /* IPv4 packet? */
				c->ipv4++;                                            /* count it */

				uint8_t *ip = pkt + ETH_HDR_LEN;                      /* IPv4 header starts right after Ethernet */
				uint32_t ip_hdr_len = (ip[0] % 16) * 4;               /* lower half of byte 0 = header length in 4-byte units */
				uint8_t *l4 = ip + ip_hdr_len;                        /* TCP/UDP header follows the IP header */

				uint8_t  proto    = ip[IP_PROTO];                     /* 6 = TCP, 17 = UDP */
				uint32_t src_ip   = read_u32(ip + IP_SRC);
				uint32_t dst_ip   = read_u32(ip + IP_DST);
				uint16_t src_port = read_u16(l4 + L4_SRC_PORT);
				uint16_t dst_port = read_u16(l4 + L4_DST_PORT);
				flexio_dev_print("IPv4 packet: %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, proto=%u, len=%u\n",
					(src_ip >> 24) & 0xff, (src_ip >> 16) & 0xff, (src_ip >> 8) & 0xff, src_ip & 0xff, src_port,
					(dst_ip >> 24) & 0xff, (dst_ip >> 16) & 0xff, (dst_ip >> 8) & 0xff, dst_ip & 0xff, dst_port,
					proto, len);
			}
		}

		c->count++;                                                   /* count every packet */
		flexio_dev_dbr_cq_set_ci((uint32_t *)c->cq_dbr, ++c->cq_ci);  /* consume the CQE and tell the NIC the slot is free */
		flexio_dev_dbr_rq_inc_pi((uint32_t *)c->rq_dbr); /* recycle the RX buffer; only after parsing, NIC may overwrite it now */
	}

	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);  /* make the doorbell writes visible before arming */
	flexio_dev_cq_arm(c->cq_ci, c->cq_num);              /* request the next event for CQEs from cq_ci on */
	flexio_dev_thread_reschedule();                      /* give the DPA core back, we are woken up by the next event */
}

__dpa_rpc__ uint64_t get_count(uint64_t arg)          /* RPC the host calls via flexio_process_call() */
{
	return ((struct pkt_ctx *)arg)->count;            /* arg = ctx address, return the packet counter */
}

__dpa_rpc__ uint64_t get_ipv4(uint64_t arg)           /* second RPC for the IPv4 counter */
{
	return ((struct pkt_ctx *)arg)->ipv4;             /* arg = ctx address, return the IPv4 counter */
}
