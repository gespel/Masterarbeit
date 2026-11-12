#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>

/* Result of one spin() RPC, written by the DPA into a device buffer that the
 * host passes in, so the host also learns how far the RPC got. */
struct spin_result {
	uint64_t requested_us;  /* how long the RPC was asked to run            */
	uint64_t elapsed_us;    /* rdtime delta (1 MHz wall clock on the DPA)    */
	uint64_t cycles;        /* __dpa_thread_cycles delta (stops when halted?) */
	uint64_t ticks;         /* number of gdb_tick() calls                    */
	uint64_t done;          /* 1 once the loop finished                      */
};

/* gdb_tick() is called once per TICK_US of wall time; a gdb breakpoint on it
 * halts the RPC thread periodically. */
#define TICK_US 100000ULL

#endif // COMMON_H
