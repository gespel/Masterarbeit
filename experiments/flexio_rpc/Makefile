DOCA := /opt/mellanox/doca
MCPU := nv-dpa-bf3,nv-dpa-cx7,nv-dpa-cx8

flexio_rpc: host.c device_prog.a
	gcc -o $@ host.c device_prog.a $(shell pkg-config --cflags --libs libflexio libibverbs)

device_prog.a: device/kernel.c
	$(DOCA)/tools/dpacc $< -o $@ -mcpu=$(MCPU) -hostcc=gcc --app-name=flexio_rpc_app -flto \
		--devicecc-options="-ffreestanding -mcmodel=medany -O2"

clean:
	rm -f flexio_rpc device_prog.a
