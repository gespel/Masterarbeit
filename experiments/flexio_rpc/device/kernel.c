#include <libflexio-dev/flexio_dev_ver.h>
#define FLEXIO_DEV_VER_USED FLEXIO_DEV_VER(26, 4, 0)
#include <libflexio-dev/flexio_dev.h>

__dpa_rpc__ uint64_t add(uint64_t a, uint64_t b)
{
	return a + b;
}
