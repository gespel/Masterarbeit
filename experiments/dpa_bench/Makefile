DOCA  := /opt/mellanox/doca
LIBDIR := $(shell pkg-config --variable=libdir doca-dpa)
MCPU  := nv-dpa-bf3,nv-dpa-cx7,nv-dpa-cx8

dpa_bench: host.c device_prog.a
	gcc -DDOCA_ALLOW_EXPERIMENTAL_API -o $@ host.c device_prog.a \
		$(shell pkg-config --cflags --libs doca-common doca-dpa libflexio)

device_prog.a: device/kernel.c
	$(DOCA)/tools/dpacc $< -o $@ -mcpu=$(MCPU) -hostcc=gcc --app-name=dpa_bench_app \
		-device-libs="-L$(LIBDIR) -ldoca_dpa_dev" -flto -I$(DOCA)/include \
		--devicecc-options="-DDOCA_ALLOW_EXPERIMENTAL_API -O2"

clean:
	rm -f dpa_bench device_prog.a
