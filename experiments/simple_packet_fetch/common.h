/* Shared host/DPA state, lives in DPA heap memory. */
#include <stdint.h>                       /* fixed-width integer types for both sides */

#define LOG_Q_DEPTH 7                     /* 128 entries for RQ and CQ */
#define BUF_BSIZE   2048                  /* RX buffer per packet, needed by host (alloc) and DPA (addressing) */

struct pkt_ctx {
	uint64_t cq_ring, cq_dbr, rq_dbr; /* DPA addresses */
	uint64_t rx_bufs;                 /* DPA address of the RX buffers */
	uint32_t cq_num;                  /* CQ number, needed to arm the CQ */
	uint32_t cq_ci;                   /* CQ consumer index */
	uint32_t sf_dev_id;               /* extended UAR id: points the outbox at the SF that owns the CQ */
	uint64_t count;                   /* received packets */
	uint64_t ipv4;                    /* received IPv4 packets */
};
