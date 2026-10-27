import os
import sys
import argparse



if __name__ == "__main__":
    main()    

def main() -> None:
    parser = argparse.ArgumentParser(description="flexio-template")
    parser.add_argument("--name", type=str, required=True, help="Name of the flexio-template")
    args = parser.parse_args()

    print(f"Creating flexio-template with name: {args.name}")

    name = args.name

    os.makedirs(name, exist_ok=True)
    with open(os.path.join(name, "Makefile"), "w") as f:
        f.write(f"""
DOCA := /opt/mellanox/doca
MCPU := nv-dpa-bf3,nv-dpa-cx7,nv-dpa-cx8

{name}: host.c common.h device_prog.a
	gcc -DFLEXIO_ALLOW_EXPERIMENTAL_API -o $@ host.c device_prog.a $(shell pkg-config --cflags --libs libflexio libibverbs libmlx5)

device_prog.a: device/kernel.c common.h
	$(DOCA)/tools/dpacc $< -o $@ -mcpu=$(MCPU) -hostcc=gcc --app-name={name}_app -flto --devicecc-options="-DFLEXIO_DEV_ALLOW_EXPERIMENTAL_API -DE_MODE_LE -ffreestanding -mcmodel=medany -O2"

clean:
	rm -f {name} device_prog.a
""")

    with open(os.path.join(name, "host.c"), "w") as f:
        f.write(f"""
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <infiniband/mlx5dv.h>
#include <libflexio/flexio_ver.h>
#define FLEXIO_VER_USED FLEXIO_VER(26, 4, 0)
#include <libflexio/flexio.h>
#include "common.h"

#define DOCA_TRY(x) do {{ if (x) {{ fprintf(stderr, "%s failed\\n", #x); exit(1); }} }} while (0)

extern flexio_func_t add;

static struct ibv_context *open_ibv(const char *name)
{{
	int num_devices;
	struct ibv_device **list = ibv_get_device_list(&num_devices);
	struct ibv_context *ctx = NULL;

	for (int i = 0; i < num_devices; i++) {{
		if (!strcmp(ibv_get_device_name(list[i]), name)) {{
			ctx = ibv_open_device(list[i]);
		}}
	}}
	ibv_free_device_list(list);
	DOCA_TRY(!ctx);
	return ctx;
}}

int main() {{
    struct ibv_context *ibv = open_ibv("mlx5_0");
	struct flexio_app *app;
	struct flexio_process *proc;
	
	struct flexio_app_select_attr sel = {{
		.app_name = "flexio_rpc_app", 
		.hw_model_id = FLEXIO_HW_MODEL_DEF, 
		.ibv_ctx = ibv,
	}};

	struct flexio_msg_stream *stream;
	
	flexio_msg_stream_attr_t stream_attr = {{
		.data_bsize = 4096, 
		.sync_mode = FLEXIO_MSG_DEV_SYNC_MODE_SYNC, 
		.level = FLEXIO_MSG_DEV_INFO,
	}};
	
	uint64_t ret;

	DOCA_TRY(flexio_version_set(FLEXIO_VER_USED));
	DOCA_TRY(flexio_app_get(&sel, &app));
	DOCA_TRY(flexio_process_create(ibv, app, NULL, &proc));

	DOCA_TRY(flexio_msg_stream_create(proc, &stream_attr, stdout, NULL, &stream));

	DOCA_TRY(flexio_process_call(proc, &add, &ret, 2, 3));
	flexio_msg_stream_flush(stream);
	
	printf("add(2, 3) on DPA = %lu\\n", ret);

	flexio_msg_stream_destroy(stream);
	flexio_process_destroy(proc);
	ibv_close_device(ibv);
    return 0;
}}
""")

    with open(os.path.join(name, "common.h"), "w") as f:
        f.write(f"""
#ifndef COMMON_H
#define COMMON_H

#endif // COMMON_H
""")

    os.makedirs(os.path.join(name, "device"), exist_ok=True)

    with open(os.path.join(name, "device", "kernel.c"), "w") as f:
        f.write(f"""
#include <libflexio-dev/flexio_dev_ver.h>
#define FLEXIO_DEV_VER_USED FLEXIO_DEV_VER(26, 4, 0)
#include <libflexio-dev/flexio_dev.h>
#include <libflexio-dev/flexio_dev_queue_access.h>
#include <dpaintrin.h>
#include "../common.h"

__dpa_rpc__ uint64_t add(uint64_t a, uint64_t b) {{
	flexio_dev_print("This is on the DPA.\\n");
	return a + b;
}}

""")
