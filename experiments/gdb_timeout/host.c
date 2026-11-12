/*
 * gdb_timeout: does an attached dpa-gdbserver session let a FlexIO RPC run
 * longer than the DPA continuous-run-time watchdog allows?
 *
 * Usage: ./gdb_timeout [-d mlx5_0] [-w] [-f] <seconds> [<seconds> ...]
 *   -d dev  IB device that owns the DPA EUs (default mlx5_0)
 *   -w      print the debug token, then wait for one line on stdin before
 *           the first spin() call (time to attach dpa-gdbserver + gdb)
 *   -f      no gdb: create the UDBG semaphore that dpa-gdbserver would create
 *           (key = low 32 bit of the udbg token) and set it to 1 (= target
 *           halted), which makes libflexio's RPC poll loop wait forever
 *
 * Why -f works (libflexio 26.04, unpacked_process_call, flexio.c:700-740):
 * the host polls the RPC CQ 600 x usleep(10 ms) = 6 s. On expiry it does
 * semget(token & 0xffffffff) + semctl(GETVAL):
 *   1 -> re-arm the 6 s poll (debugger has the target halted)
 *   2 -> re-arm only if sem_ctime is <= 5 s old (just resumed), else timeout
 *   no semaphore / other -> "Timeout on RPC polling", FLEXIO_STATUS_TIMEOUT
 *
 * For every <seconds> one spin() RPC is issued. Output is one CSV line per
 * call on stdout (header first); diagnostics go to stderr.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <infiniband/mlx5dv.h>
#include <libflexio/flexio_ver.h>
#define FLEXIO_VER_USED FLEXIO_VER(26, 4, 0)
#include <libflexio/flexio.h>
#include "common.h"

#define DOCA_TRY(x) do { if (x) { fprintf(stderr, "%s failed\n", #x); exit(1); } } while (0)

extern flexio_func_t add;
extern flexio_func_t spin;
extern flexio_func_t read_u64;

static struct ibv_context *open_ibv(const char *name)
{
	int num_devices;
	struct ibv_device **list = ibv_get_device_list(&num_devices);
	struct ibv_context *ctx = NULL;

	for (int i = 0; i < num_devices; i++) {
		if (!strcmp(ibv_get_device_name(list[i]), name)) {
			ctx = ibv_open_device(list[i]);
		}
	}
	ibv_free_device_list(list);
	DOCA_TRY(!ctx);
	return ctx;
}

static uint64_t now_us(void)
{
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC, &ts);
	return ts.tv_sec * 1000000ULL + ts.tv_nsec / 1000;
}

/* Read one field of the device-side spin_result; UINT64_MAX if the RPC fails
 * (i.e. the process no longer accepts calls). */
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
	int wait_gdb = 0;
	int fake_sem = 0;
	int semid = -1;
	int opt;

	while ((opt = getopt(argc, argv, "d:wf")) != -1) {
		switch (opt) {
		case 'd': dev = optarg; break;
		case 'w': wait_gdb = 1; break;
		case 'f': fake_sem = 1; break;
		default:
			fprintf(stderr, "usage: %s [-d dev] [-w] [-f] <seconds>...\n", argv[0]);
			return 2;
		}
	}
	if (optind >= argc) {
		fprintf(stderr, "usage: %s [-d dev] [-w] [-f] <seconds>...\n", argv[0]);
		return 2;
	}

	struct ibv_context *ibv = open_ibv(dev);
	struct flexio_app *app;
	struct flexio_process *proc;
	struct flexio_app_select_attr sel = {
		.app_name = "gdb_timeout_app",
		.hw_model_id = FLEXIO_HW_MODEL_DEF,
		.ibv_ctx = ibv,
	};
	struct flexio_msg_stream *stream;
	flexio_msg_stream_attr_t stream_attr = {
		.data_bsize = 4096,
		.sync_mode = FLEXIO_MSG_DEV_SYNC_MODE_SYNC,
		.level = FLEXIO_MSG_DEV_INFO,
	};
	flexio_uintptr_t res_daddr;
	uint64_t ret;

	DOCA_TRY(flexio_version_set(FLEXIO_VER_USED));
	DOCA_TRY(flexio_app_get(&sel, &app));
	DOCA_TRY(flexio_process_create(ibv, app, NULL, &proc));
	DOCA_TRY(flexio_msg_stream_create(proc, &stream_attr, stderr, NULL, &stream));
	DOCA_TRY(flexio_buf_dev_alloc(proc, sizeof(struct spin_result), &res_daddr));

	DOCA_TRY(flexio_process_call(proc, &add, &ret, 2, 3));
	flexio_msg_stream_flush(stream);

	fprintf(stderr, "device             : %s\n", dev);
	fprintf(stderr, "cont_run_time_max  : %u s\n", flexio_process_thread_cont_run_time_max_get(proc));
	fprintf(stderr, "udbg_token         : %#lx\n", flexio_process_udbg_token_get(proc));
	fprintf(stderr, "result daddr       : %#lx\n", (unsigned long)res_daddr);
	fflush(stderr);

	if (fake_sem) {
		key_t key = (key_t)(uint32_t)flexio_process_udbg_token_get(proc);
		semid = semget(key, 1, IPC_CREAT | 0666);
		DOCA_TRY(semid < 0);
		DOCA_TRY(semctl(semid, 0, SETVAL, 1));
		fprintf(stderr, "fake UDBG semaphore: key %#x semid %d value 1\n", key, semid);
	}

	if (wait_gdb) {
		char line[64];
		/* machine-readable line for run_gdb.sh */
		printf("# TOKEN %#lx\n", flexio_process_udbg_token_get(proc));
		printf("# attach: dpa-gdbserver %s -T %#lx -s 1981, then send a line on stdin\n",
		       dev, flexio_process_udbg_token_get(proc));
		fflush(stdout);
		if (!fgets(line, sizeof(line), stdin))
			fprintf(stderr, "stdin closed, continuing\n");
	}

	printf("requested_s,status,err_status,wall_ms,ret_elapsed_ms,"
	       "dev_elapsed_ms,dev_cycles,dev_ticks,dev_done\n");
	fflush(stdout);

	int alive = 1;
	for (int i = optind; i < argc && alive; i++) {
		double secs = atof(argv[i]);
		uint64_t usec = (uint64_t)(secs * 1e6);
		uint64_t t0, t1;
		flexio_status st;

		ret = 0;
		t0 = now_us();
		st = flexio_process_call(proc, &spin, &ret, usec, (uint64_t)res_daddr);
		t1 = now_us();
		flexio_msg_stream_flush(stream);

		int err = flexio_err_status_get(proc);
		uint64_t el = read_field(proc, res_daddr, offsetof(struct spin_result, elapsed_us));
		uint64_t cy = read_field(proc, res_daddr, offsetof(struct spin_result, cycles));
		uint64_t tk = read_field(proc, res_daddr, offsetof(struct spin_result, ticks));
		uint64_t dn = read_field(proc, res_daddr, offsetof(struct spin_result, done));

		printf("%.3f,%d,%d,%.1f,%.1f,", secs, st, err, (t1 - t0) / 1e3,
		       st == FLEXIO_STATUS_SUCCESS ? ret / 1e3 : -1.0);
		if (el == UINT64_MAX)
			printf("NA,NA,NA,NA\n");
		else
			printf("%.1f,%lu,%lu,%lu\n", el / 1e3, cy, tk, dn);
		fflush(stdout);

		if (st != FLEXIO_STATUS_SUCCESS || err) {
			fprintf(stderr, "spin(%.3f s) failed: status %d, err_status %d\n", secs, st, err);
			alive = 0;
		}
	}

	if (semid >= 0)
		semctl(semid, 0, IPC_RMID);
	flexio_msg_stream_destroy(stream);
	flexio_buf_dev_free(proc, res_daddr);
	flexio_process_destroy(proc);
	ibv_close_device(ibv);
	return alive ? 0 : 1;
}
