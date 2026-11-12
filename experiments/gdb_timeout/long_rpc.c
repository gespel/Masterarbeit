/* Minimal: run one RPC longer than libflexio's 6 s poll timeout.
 * ./long_rpc <seconds> */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/sem.h>
#include <infiniband/verbs.h>
#include <libflexio/flexio_ver.h>
#define FLEXIO_VER_USED FLEXIO_VER(26, 4, 0)
#include <libflexio/flexio.h>

extern flexio_func_t busy_us;

int main(int argc, char **argv)
{
	uint64_t usec = (uint64_t)(atof(argc > 1 ? argv[1] : "30") * 1e6), ret;
	printf("requesting %llu us on the DPA\n", (unsigned long long)usec);
	struct ibv_device **devs = ibv_get_device_list(NULL);
	struct ibv_context *ibv = NULL;
	struct flexio_app *app;
	struct flexio_process *proc;

	for (int i = 0; devs[i]; i++)
		if (!strcmp(ibv_get_device_name(devs[i]), "mlx5_0"))
			ibv = ibv_open_device(devs[i]);
	ibv_free_device_list(devs);

	struct flexio_app_select_attr sel = {
		.app_name = "gdb_timeout_app", .hw_model_id = FLEXIO_HW_MODEL_DEF, .ibv_ctx = ibv,
	};
	flexio_version_set(FLEXIO_VER_USED);
	if (!ibv || flexio_app_get(&sel, &app) || flexio_process_create(ibv, app, NULL, &proc))
		return 1;

	// Der Trick: pretend dpa-gdbserver has the target halted (value 1), so libflexio re-arms its RPC poll timeout forever.
	int sem = semget((key_t)(uint32_t)flexio_process_udbg_token_get(proc), 1, IPC_CREAT | 0666);
	semctl(sem, 0, SETVAL, 1);

	flexio_status st = flexio_process_call(proc, &busy_us, &ret, usec);
	printf("status %d, ran %.1f s on the DPA\n", st, ret / 1e6);

	semctl(sem, 0, IPC_RMID);
	flexio_process_destroy(proc);
	ibv_close_device(ibv);
	return st;
}
