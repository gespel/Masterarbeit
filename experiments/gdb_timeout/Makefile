
DOCA := /opt/mellanox/doca
MCPU := nv-dpa-bf3,nv-dpa-cx7,nv-dpa-cx8

all: gdb_timeout long_rpc

gdb_timeout: host.c common.h device_prog.a
	gcc -DFLEXIO_ALLOW_EXPERIMENTAL_API -o $@ host.c device_prog.a $(shell pkg-config --cflags --libs libflexio libibverbs libmlx5)

long_rpc: long_rpc.c device_prog.a
	gcc -DFLEXIO_ALLOW_EXPERIMENTAL_API -o $@ long_rpc.c device_prog.a $(shell pkg-config --cflags --libs libflexio libibverbs libmlx5)

device_prog.a: device/kernel.c common.h
	$(DOCA)/tools/dpacc $< -o $@ -mcpu=$(MCPU) -hostcc=gcc --app-name=gdb_timeout_app -flto --devicecc-options="-DFLEXIO_DEV_ALLOW_EXPERIMENTAL_API -DE_MODE_LE -ffreestanding -mcmodel=medany -O2 -g"

.PHONY: all clean

clean:
	rm -f gdb_timeout long_rpc device_prog.a
