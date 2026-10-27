
#include <libflexio-dev/flexio_dev_ver.h>
#define FLEXIO_DEV_VER_USED FLEXIO_DEV_VER(26, 4, 0)
#include <libflexio-dev/flexio_dev.h>
#include <libflexio-dev/flexio_dev_queue_access.h>
#include <dpaintrin.h>
#include "../common.h"

__dpa_rpc__ uint64_t add(uint64_t a, uint64_t b) {
	flexio_dev_print("This is on the DPA.\n");
	return a + b;
}

