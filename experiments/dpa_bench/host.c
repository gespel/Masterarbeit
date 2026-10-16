#include <stdio.h>
#include <stdlib.h>
#include <doca_dev.h>
#include <doca_dpa.h>
#include <doca_sync_event.h>

#define CHECK(x) do { doca_error_t r_ = (x); if (r_ != DOCA_SUCCESS) { \
	fprintf(stderr, "%s failed: %s\n", #x, doca_error_get_descr(r_)); exit(1); } } while (0)

extern struct doca_dpa_app *dpa_bench_app;
extern doca_dpa_func_t hello;

static struct doca_dev *open_dpa_dev(void) {
	struct doca_devinfo **list;
	struct doca_dev *dev = NULL;
	uint32_t n;

	CHECK(doca_devinfo_create_list(&list, &n));
	for (uint32_t i = 0; i < n && !dev; i++)
		if (doca_dpa_cap_is_supported(list[i]) == DOCA_SUCCESS)
			CHECK(doca_dev_open(list[i], &dev));
	doca_devinfo_destroy_list(list);
	if (!dev) { fprintf(stderr, "no DPA device found\n"); exit(1); }
	return dev;
}

int main(void) {
	struct doca_dev *dev = open_dpa_dev();
	struct doca_dpa *dpa;
	struct doca_sync_event *done;

	CHECK(doca_dpa_create(dev, &dpa));
	CHECK(doca_dpa_set_app(dpa, dpa_bench_app));
	CHECK(doca_dpa_start(dpa));

	CHECK(doca_sync_event_create(&done));
	CHECK(doca_sync_event_add_publisher_location_dpa(done, dpa));
	CHECK(doca_sync_event_add_subscriber_location_cpu(done, dev));
	CHECK(doca_sync_event_start(done));

	CHECK(doca_dpa_kernel_launch_update_set(dpa, NULL, 0, done, 1, 1, &hello));
	CHECK(doca_sync_event_wait_gt(done, 0, UINT64_MAX));
	printf("kernel done\n");

	doca_sync_event_destroy(done);
	doca_dpa_destroy(dpa);
	doca_dev_close(dev);
	return 0;
}
