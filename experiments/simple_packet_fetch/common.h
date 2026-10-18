/* Shared host/DPA state, lives in DPA heap memory. */
#include <stdint.h>

#define LOG_Q_DEPTH 7 /* 128 entries for RQ and CQ */

struct pkt_ctx {
	uint64_t cq_ring, cq_dbr, rq_dbr; /* DPA addresses */
	uint32_t cq_num;
	uint32_t cq_ci;                   /* CQ consumer index */
	uint64_t count;                   /* received packets */
};
