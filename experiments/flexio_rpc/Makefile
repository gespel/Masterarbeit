DOCA := /opt/mellanox/doca
LIBDIR := $(shell pkg-config --variable=libdir doca-dpa)
MCPU := nv-dpa-bf3,nv-dpa-cx7,nv-dpa-cx8

flexio_rpc: host.c device_prog.a
	gcc -o $@ host.c device_prog.a $(shell pkg-config --cflags --libs libflexio libibverbs doca-dpa)

device_prog.a: device/kernel.c
	$(DOCA)/tools/dpacc $< -o $@ -mcpu=$(MCPU) -hostcc=gcc --app-name=flexio_rpc_app \
		--devicecc-options="-ffreestanding -mcmodel=medany -O2 -DDOCA_ALLOW_EXPERIMENTAL_API -DFLEXIO_DEV_ALLOW_EXPERIMENTAL_API" -device-libs="-L$(LIBDIR) -ldoca_dpa_dev" -flto -I$(DOCA)/include
clean:
	rm -f flexio_rpc device_prog.a
