/*
 * eh_watchdog: is cont_run_time_max (100 s) enforced for event-handler
 * threads? An RPC can't answer that, because libflexio kills the RPC thread
 * after its 6 s host poll timeout. Here the busy loop runs in an event
 * handler (flexio_event_handler_run() arms it, the eh_activate() RPC triggers
 * it via flexio_dev_event_handler_activate()), so the host does not wait on it.
 *
 * Usage: ./eh_watchdog [-d mlx5_0] <seconds>
 *
 * Once per second the host prints one CSV line: wall time, flexio_err_status_get(),
 * and the handler's progress (elapsed/ticks/done, read with read_u64() RPCs).
 * It stops when the handler is done, an error is reported, the progress RPC
 * fails, or the handler makes no progress for 10 s.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <infiniband/verbs.h>
#include <libflexio/flexio_ver.h>
#define FLEXIO_VER_USED FLEXIO_VER(26, 4, 0)
#include <libflexio/flexio.h>
#include "common.h"

#define TRY(x) do { if (x) { fprintf(stderr, "%s failed\n", #x); exit(1); } } while (0)

extern flexio_func_t eh_spin;
extern flexio_func_t read_u64;
extern flexio_func_t eh_activate;

static uint64_t now_us(void)
{
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC, &ts);
	return ts.tv_sec * 1000000ULL + ts.tv_nsec / 1000;
}

static uint64_t read_field(struct flexio_process *proc, flexio_uintptr_t res, size_t off)
{
	uint64_t v;
	if (flexio_process_call(proc, &read_u64, &v, (uint64_t)(res + off)) != FLEXIO_STATUS_SUCCESS)
		return UINT64_MAX;
	return v;
}

int main(int argc, char **argv)
{
	const char *dev = "mlx5_0";
	int opt;

	while ((opt = getopt(argc, argv, "d:")) != -1) {
		if (opt == 'd') {
			dev = optarg;
		} else {
			fprintf(stderr, "usage: %s [-d dev] <seconds>\n", argv[0]);
			return 2;
		}
	}
	if (optind >= argc) {
		fprintf(stderr, "usage: %s [-d dev] <seconds>\n", argv[0]);
		return 2;
	}
	double secs = atof(argv[optind]);

	struct ibv_device **devs = ibv_get_device_list(NULL);
	struct ibv_context *ibv = NULL;
	for (int i = 0; devs[i]; i++)
		if (!strcmp(ibv_get_device_name(devs[i]), dev))
			ibv = ibv_open_device(devs[i]);
	ibv_free_device_list(devs);
	TRY(!ibv);

	struct flexio_app *app;
	struct flexio_process *proc;
	struct flexio_event_handler *eh;
	struct flexio_app_select_attr sel = {
		.app_name = "gdb_timeout_app", .hw_model_id = FLEXIO_HW_MODEL_DEF, .ibv_ctx = ibv,
	};
	struct flexio_event_handler_attr eh_attr = {
		.host_stub_func = eh_spin,
		.affinity.type = FLEXIO_AFFINITY_NONE,
	};
	struct spin_result init = { .requested_us = (uint64_t)(secs * 1e6) };
	flexio_uintptr_t res;

	TRY(flexio_version_set(FLEXIO_VER_USED));
	TRY(flexio_app_get(&sel, &app));
	TRY(flexio_process_create(ibv, app, NULL, &proc));
	TRY(flexio_copy_from_host(proc, &init, sizeof(init), &res));
	TRY(flexio_event_handler_create(proc, &eh_attr, &eh));

	fprintf(stderr, "device            : %s\n", dev);
	fprintf(stderr, "cont_run_time_max : %u s\n", flexio_process_thread_cont_run_time_max_get(proc));
	fprintf(stderr, "requested         : %.1f s\n", secs);

	printf("wall_s,err_status,dev_elapsed_s,dev_ticks,dev_done\n");
	fflush(stdout);

	uint64_t ret, t0;
	uint32_t act_id = flexio_event_handler_get_activation_id(eh);
	TRY(act_id == UINT32_MAX);
	TRY(flexio_event_handler_run(eh, (uint64_t)res));
	t0 = now_us();
	TRY(flexio_process_call(proc, &eh_activate, &ret, (uint64_t)act_id));

	uint64_t last_el = 0, last_change = t0;
	int rc = 0;
	for (;;) {
		sleep(1);
		uint64_t t = now_us();
		int err = flexio_err_status_get(proc);
		uint64_t el = read_field(proc, res, offsetof(struct spin_result, elapsed_us));
		uint64_t tk = read_field(proc, res, offsetof(struct spin_result, ticks));
		uint64_t dn = read_field(proc, res, offsetof(struct spin_result, done));

		if (el == UINT64_MAX) {
			printf("%.1f,%d,NA,NA,NA\n", (t - t0) / 1e6, err);
			fprintf(stderr, "progress RPC failed\n");
			rc = 1;
			break;
		}
		printf("%.1f,%d,%.1f,%lu,%lu\n", (t - t0) / 1e6, err, el / 1e6, tk, dn);
		fflush(stdout);

		if (el != last_el) {
			last_el = el;
			last_change = t;
		}
		if (dn) {
			fprintf(stderr, "handler finished: %.1f s, %lu cycles\n", el / 1e6,
				read_field(proc, res, offsetof(struct spin_result, cycles)));
			break;
		}
		if (err) {
			fprintf(stderr, "err_status %d after %.1f s wall\n", err, (t - t0) / 1e6);
			rc = 1;
			break;
		}
		if (t - last_change > 10000000) {
			fprintf(stderr, "no progress for 10 s, handler stopped at %.1f s\n", el / 1e6);
			rc = 1;
			break;
		}
	}

	fprintf(stderr, "final err_status  : %d\n", flexio_err_status_get(proc));
	flexio_event_handler_destroy(eh);
	flexio_buf_dev_free(proc, res);
	flexio_process_destroy(proc);
	ibv_close_device(ibv);
	return rc;
}
