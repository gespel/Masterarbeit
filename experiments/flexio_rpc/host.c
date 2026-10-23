#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <infiniband/verbs.h>
#include <libflexio/flexio_ver.h>
#define FLEXIO_VER_USED FLEXIO_VER(26, 4, 0)
#include <libflexio/flexio.h>

#define DOCA_TRY(x) do { if (x) { fprintf(stderr, "%s failed\n", #x); exit(1); } } while (0)

extern flexio_func_t add;

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

int main(int argc, char **argv)
{
	struct ibv_context *ibv = open_ibv(argc > 1 ? argv[1] : "mlx5_0");
	struct flexio_app *app;
	struct flexio_process *proc;
	struct flexio_app_select_attr sel = {
		.app_name = "flexio_rpc_app", .hw_model_id = FLEXIO_HW_MODEL_DEF, .ibv_ctx = ibv,
	};
	struct flexio_msg_stream *stream;
	flexio_msg_stream_attr_t stream_attr = {
		.data_bsize = 4096, .sync_mode = FLEXIO_MSG_DEV_SYNC_MODE_SYNC, .level = FLEXIO_MSG_DEV_INFO,
	};
	uint64_t ret;

	DOCA_TRY(flexio_version_set(FLEXIO_VER_USED));
	DOCA_TRY(flexio_app_get(&sel, &app));
	DOCA_TRY(flexio_process_create(ibv, app, NULL, &proc));
	/* First stream created is the default stream (id 0) used by flexio_dev_print */
	DOCA_TRY(flexio_msg_stream_create(proc, &stream_attr, stdout, NULL, &stream));

	DOCA_TRY(flexio_process_call(proc, &add, &ret, 2, 3));
	flexio_msg_stream_flush(stream);
	printf("add(2, 3) on DPA = %lu\n", ret);

	flexio_msg_stream_destroy(stream);
	flexio_process_destroy(proc);
	ibv_close_device(ibv);
	return 0;
}
