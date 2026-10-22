#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <infiniband/verbs.h>
#include <libflexio/flexio_ver.h>
#define FLEXIO_VER_USED FLEXIO_VER(26, 4, 0)
#include <libflexio/flexio.h>

#define TRY(x) do { if (x) { fprintf(stderr, "%s failed\n", #x); exit(1); } } while (0)

extern flexio_func_t add;

static struct ibv_context *open_ibv(const char *name)
{
	struct ibv_device **list = ibv_get_device_list(NULL);
	struct ibv_context *ctx = NULL;

	for (int i = 0; list && list[i] && !ctx; i++)
		if (!strcmp(ibv_get_device_name(list[i]), name))
			ctx = ibv_open_device(list[i]);
	ibv_free_device_list(list);
	TRY(!ctx);
	return ctx;
}

int main(int argc, char **argv)
{
	struct ibv_context *ibv = open_ibv(argc > 1 ? argv[1] : "mlx5_0");
	struct flexio_app *app;
	struct flexio_process *proc;
	struct flexio_app_select_attr sel = {
		.app_name = "flexio_rpc_app", .hw_model_id = FLEXIO_HW_MODEL_DEF, .ibv_ctx = ibv,
	};
	uint64_t ret;

	TRY(flexio_version_set(FLEXIO_VER_USED));
	TRY(flexio_app_get(&sel, &app));
	TRY(flexio_process_create(ibv, app, NULL, &proc));

	TRY(flexio_process_call(proc, &add, &ret, 2, 3));
	printf("add(2, 3) on DPA = %lu\n", ret);

	flexio_process_destroy(proc);
	ibv_close_device(ibv);
	return 0;
}
