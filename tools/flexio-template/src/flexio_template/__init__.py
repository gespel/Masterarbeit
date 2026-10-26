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

int main() {{
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
""")
