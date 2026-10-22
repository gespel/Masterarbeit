DOCA  := /opt/mellanox/doca
LIBDIR := $(shell pkg-config --variable=libdir doca-dpa)
MCPU  := nv-dpa-bf3,nv-dpa-cx7,nv-dpa-cx8
DPACLANG := $(DOCA)/tools/dpa-clang

dpa_bench: host.c common.h device_prog.a
	gcc -DDOCA_ALLOW_EXPERIMENTAL_API -o $@ host.c device_prog.a \
		$(shell pkg-config --cflags --libs doca-common doca-dpa libflexio)

device_prog.a: device/kernel.c common.h
	$(DOCA)/tools/dpacc $< -o $@ -mcpu=$(MCPU) -hostcc=gcc --app-name=dpa_bench_app \
		-device-libs="-L$(LIBDIR) -ldoca_dpa_dev" -flto -I$(DOCA)/include \
		--devicecc-options="-DDOCA_ALLOW_EXPERIMENTAL_API -O2"

# clangd can't read Makefiles or dpacc: generate a compile DB instead.
# The device entry replays dpa-clang's predefined macros (__dpa_global__,
# intrinsics versions, ...) because the system clangd doesn't know them.
DEV_FLAGS  := --target=riscv64 -ffreestanding -mcmodel=medany -undef -include $(CURDIR)/.dpa_predef.h \
	-DDOCA_ALLOW_EXPERIMENTAL_API -I$(DOCA)/include -isystem /opt/mellanox/flexio/include \
	-isystem $(shell $(DPACLANG) -print-resource-dir)/include
HOST_FLAGS := -DDOCA_ALLOW_EXPERIMENTAL_API $(shell pkg-config --cflags doca-common doca-dpa libflexio)

compile_commands.json: Makefile
	$(DPACLANG) --target=riscv64 -ffreestanding -mcmodel=medany -mcpu=nv-dpa-bf3 -dM -E -x c /dev/null > .dpa_predef.h
	printf '[\n{"directory":"%s","file":"device/kernel.c","command":"clang %s -c device/kernel.c"},\n{"directory":"%s","file":"host.c","command":"gcc %s -c host.c"}\n]\n' \
		"$(CURDIR)" "$(DEV_FLAGS)" "$(CURDIR)" "$(HOST_FLAGS)" > $@

clean:
	rm -f dpa_bench device_prog.a
