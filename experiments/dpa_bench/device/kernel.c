#include <doca_dpa_dev.h>

__dpa_global__ void hello(void)
{
	DOCA_DPA_DEV_LOG_INFO("Hello from DPA\n");
}
