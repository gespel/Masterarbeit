DOCA := /opt/mellanox/doca
MCPU := nv-dpa-bf3,nv-dpa-cx7,nv-dpa-cx8

hashing: host.c common.h device_prog.a
	gcc -DFLEXIO_ALLOW_EXPERIMENTAL_API -o $@ host.c device_prog.a \
		$(shell pkg-config --cflags --libs libflexio libibverbs libmlx5)

device_prog.a: device/kernel.c common.h
	$(DOCA)/tools/dpacc $< -o $@ -mcpu=$(MCPU) -hostcc=gcc --app-name=hashing_app -flto \
		--devicecc-options="-DFLEXIO_DEV_ALLOW_EXPERIMENTAL_API -DE_MODE_LE -ffreestanding -mcmodel=medany -O2"

clean:
	rm -f hashing device_prog.a