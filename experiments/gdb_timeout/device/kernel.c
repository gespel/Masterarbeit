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

volatile uint64_t gdb_tick_sink;

__attribute__((noinline)) void gdb_tick(uint64_t n)
{
	gdb_tick_sink = n;
}

__dpa_rpc__ uint64_t spin(uint64_t usec, uint64_t res_daddr)
{
	struct spin_result *res = (struct spin_result *)res_daddr;
	uint64_t t0 = __dpa_thread_time();
	uint64_t c0 = __dpa_thread_cycles();
	uint64_t next_tick = t0 + TICK_US;
	uint64_t ticks = 0;
	uint64_t now;

	res->requested_us = usec;
	res->done = 0;

	do {
		now = __dpa_thread_time();
		if (now >= next_tick) {
			gdb_tick(++ticks);
			next_tick += TICK_US;
			res->ticks = ticks;
			res->elapsed_us = now - t0;
			__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
		}
	} while (now - t0 < usec);

	res->elapsed_us = now - t0;
	res->cycles = __dpa_thread_cycles() - c0;
	res->ticks = ticks;
	res->done = 1;
	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
	return now - t0;
}

__dpa_rpc__ uint64_t read_u64(uint64_t daddr)
{
	return *(volatile uint64_t *)daddr;
}

__dpa_rpc__ uint64_t busy_us(uint64_t usec)
{
	uint64_t t0 = __dpa_thread_time();
	while (__dpa_thread_time() - t0 < usec)
		;
	return __dpa_thread_time() - t0;
}

flexio_dev_event_handler_t eh_spin;
__dpa_global__ void eh_spin(uint64_t arg)
{
	struct spin_result *res = (struct spin_result *)arg;
	uint64_t usec = res->requested_us;
	uint64_t t0 = __dpa_thread_time();
	uint64_t c0 = __dpa_thread_cycles();
	uint64_t next_tick = t0 + TICK_US;
	uint64_t ticks = 0;
	uint64_t now;

	do {
		now = __dpa_thread_time();
		if (now >= next_tick) {
			next_tick += TICK_US;
			res->ticks = ++ticks;
			res->elapsed_us = now - t0;
			__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
		}
	} while (now - t0 < usec);

	res->elapsed_us = now - t0;
	res->cycles = __dpa_thread_cycles() - c0;
	res->ticks = ticks;
	res->done = 1;
	__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W);
	flexio_dev_thread_finish();
}

__dpa_rpc__ uint64_t eh_activate(uint64_t activation_id)
{
	flexio_dev_event_handler_activate((uint32_t)activation_id);
	return 0;
}
