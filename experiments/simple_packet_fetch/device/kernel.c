#include <libflexio-dev/flexio_dev_ver.h>
#define FLEXIO_DEV_VER_USED FLEXIO_DEV_VER(26, 4, 0)
#include <libflexio-dev/flexio_dev.h>
#include <libflexio-dev/flexio_dev_queue_access.h>
#include <dpaintrin.h>
#include "../common.h"

#define Q_MASK ((1u << LOG_Q_DEPTH) - 1)

/* Runs whenever a CQE lands on the armed RQ CQ. */
flexio_dev_event_handler_t pkt_handler;
__dpa_global__ void pkt_handler(uint64_t arg)
{
	struct pkt_ctx *c = (struct pkt_ctx *)arg;
	struct flexio_dev_cqe64 *ring = (struct flexio_dev_cqe64 *)c->cq_ring;

	/* A CQE is new if its owner bit matches the current wrap-around parity. */
	while (flexio_dev_cqe_get_owner(&ring[c->cq_ci & Q_MASK]) == ((c->cq_ci >> LOG_Q_DEPTH) & 1)) {
		c->count++;
		flexio_dev_dbr_cq_set_ci((uint32_t *)c->cq_dbr, ++c->cq_ci);
		flexio_dev_dbr_rq_inc_pi((uint32_t *)c->rq_dbr); /* recycle the RX buffer */
	}

	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
	flexio_dev_cq_arm(c->cq_ci, c->cq_num);
	flexio_dev_thread_reschedule();
}

__dpa_rpc__ uint64_t get_count(uint64_t arg)
{
	return ((struct pkt_ctx *)arg)->count;
}
