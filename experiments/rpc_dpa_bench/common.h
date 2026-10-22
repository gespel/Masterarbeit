#ifndef RPC_DPA_BENCH_COMMON_H
#define RPC_DPA_BENCH_COMMON_H

#include <stdint.h>

/* Per-thread slot in DPA memory: inputs written by host, results by device */
struct nn_thread_args {
	/* in */
	uint64_t se;		/* doca_dpa_dev_sync_event_t, +1 when done */
	uint64_t iters;
	uint32_t seed;
	uint32_t eu;
	/* out */
	uint64_t start_time;	/* __dpa_thread_time(), us */
	uint64_t end_time;
	uint64_t cycles;
	uint64_t class_count[2];
};

#endif
