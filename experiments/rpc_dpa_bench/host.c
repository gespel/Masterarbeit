#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <doca_dev.h>
#include <doca_dpa.h>
#include <doca_sync_event.h>
#include <time.h>
#include "common.h"

#define DOCA_TRY(x) do { doca_error_t r_ = (x); if (r_ != DOCA_SUCCESS) { \
	fprintf(stderr, "%s failed: %s\n", #x, doca_error_get_descr(r_)); exit(1); } } while (0)

extern struct doca_dpa_app *dpa_bench_app;
extern doca_dpa_func_t hello;
extern doca_dpa_func_t calc_primes;
extern doca_dpa_func_t small_neural_network;
extern doca_dpa_func_t nn_thread;
extern doca_dpa_func_t nn_notify_threads;

#define MAX_EUS_PER_CORE 16

static struct doca_dev *open_dpa_dev(void) {
	struct doca_devinfo **list;
	struct doca_dev *dev = NULL;
	uint32_t n;

	DOCA_TRY(doca_devinfo_create_list(&list, &n));
	for (uint32_t i = 0; i < n && !dev; i++)
		if (doca_dpa_cap_is_supported(list[i]) == DOCA_SUCCESS)
			DOCA_TRY(doca_dev_open(list[i], &dev));
	doca_devinfo_destroy_list(list);
	if (!dev) { fprintf(stderr, "no DPA device found\n"); exit(1); }
	return dev;
}

/*
Minimales starten einer RPC Funktion
Device (device/kernel.c):


__dpa_rpc__ uint64_t hello(void) {
	DOCA_DPA_DEV_LOG_INFO("Hello from DPA\n");
	return 0;
}
Host (der Kern von main):

struct doca_dev *dev = open_dpa_dev();
struct doca_dpa *dpa;
uint64_t ret;

DOCA_TRY(doca_dpa_create(dev, &dpa));
DOCA_TRY(doca_dpa_set_app(dpa, dpa_bench_app));
DOCA_TRY(doca_dpa_set_log_level(dpa, DOCA_DPA_DEV_LOG_LEVEL_INFO));
DOCA_TRY(doca_dpa_start(dpa));

DOCA_TRY(doca_dpa_rpc(dpa, &hello, &ret));

doca_dpa_destroy(dpa);
doca_dev_close(dev);
*/

static double now_s(void) {
	struct timespec t;
	clock_gettime(CLOCK_MONOTONIC, &t);
	return t.tv_sec + t.tv_nsec * 1e-9;
}

/*
 * n = 1..max_threads model instances on n EUs (hardware threads) of the same
 * DPA core. Each thread is pinned via EU affinity (eu_id = core * eus_per_core
 * + hart), all n are woken by a single RPC, and each reports its own timing.
 * One CSV row per thread and run.
 */
static void bench_nn_same_core(struct doca_dev *dev, struct doca_dpa *dpa, unsigned int core,
			       unsigned int max_threads, uint64_t iters, int runs, const char *csv_path) {
	unsigned int num_cores, eus_per_core;
	DOCA_TRY(doca_dpa_get_core_num(dpa, &num_cores));
	DOCA_TRY(doca_dpa_get_num_eus_per_core(dpa, &eus_per_core));
	if (core >= num_cores) { fprintf(stderr, "core %u >= %u cores\n", core, num_cores); exit(1); }
	if (max_threads > eus_per_core) max_threads = eus_per_core;
	if (max_threads > MAX_EUS_PER_CORE) max_threads = MAX_EUS_PER_CORE;

	struct doca_sync_event *se;
	doca_dpa_dev_sync_event_t se_handle;
	DOCA_TRY(doca_sync_event_create(&se));
	DOCA_TRY(doca_sync_event_add_publisher_location_dpa(se, dpa));
	DOCA_TRY(doca_sync_event_add_subscriber_location_cpu(se, dev));
	DOCA_TRY(doca_sync_event_start(se));
	DOCA_TRY(doca_sync_event_get_dpa_handle(se, dpa, &se_handle));

	struct nn_thread_args args[MAX_EUS_PER_CORE];
	struct doca_dpa_thread *threads[MAX_EUS_PER_CORE];
	struct doca_dpa_notification_completion *comps[MAX_EUS_PER_CORE];
	doca_dpa_dev_uintptr_t dev_args, dev_comps;
	struct doca_dpa_eu_affinity *aff;

	DOCA_TRY(doca_dpa_mem_alloc(dpa, max_threads * sizeof(args[0]), &dev_args));
	DOCA_TRY(doca_dpa_mem_alloc(dpa, max_threads * sizeof(doca_dpa_dev_notification_completion_t), &dev_comps));
	DOCA_TRY(doca_dpa_eu_affinity_create(dpa, &aff));

	for (unsigned int i = 0; i < max_threads; i++) {
		doca_dpa_dev_notification_completion_t h;

		memset(&args[i], 0, sizeof(args[i]));
		args[i].se = se_handle;
		args[i].iters = iters;
		args[i].seed = 0x12345678 + i;	/* different weights per model */
		args[i].eu = core * eus_per_core + i;

		DOCA_TRY(doca_dpa_eu_affinity_set(aff, args[i].eu));
		DOCA_TRY(doca_dpa_thread_create(dpa, &threads[i]));
		DOCA_TRY(doca_dpa_thread_set_affinity(threads[i], aff));
		DOCA_TRY(doca_dpa_thread_set_func_arg(threads[i], &nn_thread, dev_args + i * sizeof(args[0])));
		DOCA_TRY(doca_dpa_thread_start(threads[i]));
		DOCA_TRY(doca_dpa_notification_completion_create(dpa, threads[i], &comps[i]));
		DOCA_TRY(doca_dpa_notification_completion_start(comps[i]));
		DOCA_TRY(doca_dpa_notification_completion_get_dpa_handle(comps[i], &h));
		DOCA_TRY(doca_dpa_h2d_memcpy(dpa, dev_comps + i * sizeof(h), &h, sizeof(h)));
		DOCA_TRY(doca_dpa_thread_run(threads[i]));
	}
	DOCA_TRY(doca_dpa_h2d_memcpy(dpa, dev_args, args, max_threads * sizeof(args[0])));

	FILE *csv = fopen(csv_path, "w");
	if (!csv) { perror(csv_path); exit(1); }
	fprintf(csv, "threads,run,thread,eu,start_us,end_us,dpa_time_us,cycles,cycles_per_inference,"
		     "makespan_us,host_time_s,class0,class1,inferences\n");
	printf("core %u, EUs %u..%u, %lu inferences/thread, %d runs\n",
	       core, core * eus_per_core, core * eus_per_core + max_threads - 1, iters, runs);
	printf("%7s %12s %14s %16s\n", "threads", "makespan_us", "cyc/inf(avg)", "inf/s(total)");

	uint64_t completed = 0;
	for (unsigned int n = 1; n <= max_threads; n++) {
		double sum_makespan = 0, sum_cpi = 0;

		for (int run = 1; run <= runs; run++) {
			uint64_t ret;
			double t0 = now_s();
			DOCA_TRY(doca_dpa_rpc(dpa, &nn_notify_threads, &ret, dev_comps, (uint64_t)n));
			completed += n;
			DOCA_TRY(doca_sync_event_wait_gt(se, completed - 1, UINT64_MAX));
			double host_time = now_s() - t0;

			DOCA_TRY(doca_dpa_d2h_memcpy(dpa, args, dev_args, n * sizeof(args[0])));
			uint64_t t_min = UINT64_MAX, t_max = 0;
			for (unsigned int i = 0; i < n; i++) {
				if (args[i].start_time < t_min) t_min = args[i].start_time;
				if (args[i].end_time > t_max) t_max = args[i].end_time;
			}
			uint64_t makespan = t_max - t_min;

			for (unsigned int i = 0; i < n; i++) {
				struct nn_thread_args *a = &args[i];
				uint64_t cpi = a->cycles / iters;
				fprintf(csv, "%u,%d,%u,%u,%lu,%lu,%lu,%lu,%lu,%lu,%f,%lu,%lu,%lu\n",
					n, run, i, a->eu, a->start_time - t_min, a->end_time - t_min,
					a->end_time - a->start_time, a->cycles, cpi, makespan, host_time,
					a->class_count[0], a->class_count[1], iters);
				sum_cpi += cpi;
			}
			sum_makespan += makespan;
		}
		double avg_makespan = sum_makespan / runs;
		printf("%7u %12.0f %14.0f %16.0f\n", n, avg_makespan, sum_cpi / (runs * n),
		       n * iters / (avg_makespan * 1e-6));
	}
	fclose(csv);
	printf("wrote %s\n", csv_path);

	for (unsigned int i = 0; i < max_threads; i++) {
		doca_dpa_notification_completion_stop(comps[i]);
		doca_dpa_notification_completion_destroy(comps[i]);
		doca_dpa_thread_stop(threads[i]);
		doca_dpa_thread_destroy(threads[i]);
	}
	doca_dpa_eu_affinity_destroy(aff);
	doca_dpa_mem_free(dpa, dev_comps);
	doca_dpa_mem_free(dpa, dev_args);
	doca_sync_event_stop(se);
	doca_sync_event_destroy(se);
}

int main(int argc, char **argv) {
	struct doca_dev *dev = open_dpa_dev();
	struct doca_dpa *dpa;
	struct doca_sync_event *done;

	DOCA_TRY(doca_dpa_create(dev, &dpa));
	DOCA_TRY(doca_dpa_set_app(dpa, dpa_bench_app));
	DOCA_TRY(doca_dpa_start(dpa));

	/* ./dpa_bench mt [core] [max_threads] [inferences] [runs] [csv] */
	if (argc > 1 && strcmp(argv[1], "mt") == 0) {
		unsigned int core = argc > 2 ? atoi(argv[2]) : 1;
		unsigned int max_threads = argc > 3 ? atoi(argv[3]) : MAX_EUS_PER_CORE;
		uint64_t iters = argc > 4 ? strtoull(argv[4], NULL, 10) : 10000;
		int runs = argc > 5 ? atoi(argv[5]) : 5;
		const char *csv = argc > 6 ? argv[6] : "nn_same_core.csv";

		bench_nn_same_core(dev, dpa, core, max_threads, iters, runs, csv);
		doca_dpa_destroy(dpa);
		doca_dev_close(dev);
		return 0;
	}

	DOCA_TRY(doca_sync_event_create(&done));
	DOCA_TRY(doca_sync_event_add_publisher_location_dpa(done, dpa));
	DOCA_TRY(doca_sync_event_add_subscriber_location_cpu(done, dev));
	DOCA_TRY(doca_sync_event_start(done));

	clock_t start = clock();
	DOCA_TRY(doca_dpa_kernel_launch_update_set(dpa, NULL, 0, done, 1, 1, &small_neural_network));
	//DOCA_TRY(doca_dpa_kernel_launch_update_set(dpa, NULL, 0, done, 1, 1, &calc_primes));
	DOCA_TRY(doca_sync_event_wait_gt(done, 0, UINT64_MAX));
	clock_t end = clock();
	printf("kernel done\n");
	printf("Host Execution time: %f seconds\n", (double)(end - start) / CLOCKS_PER_SEC);

	start = clock();
	//DOCA_TRY(doca_dpa_kernel_launch_update_set(dpa, NULL, 0, done, 1, 1, &small_neural_network));
	DOCA_TRY(doca_dpa_kernel_launch_update_set(dpa, NULL, 0, done, 2, 1, &calc_primes));
	DOCA_TRY(doca_sync_event_wait_gt(done, 1, UINT64_MAX));
	end = clock();
	printf("kernel done\n");
	printf("Host Execution time: %f seconds\n", (double)(end - start) / CLOCKS_PER_SEC);

	uint64_t ret;
	DOCA_TRY(doca_dpa_rpc(dpa, &hello, &ret));

	doca_sync_event_destroy(done);
	doca_dpa_destroy(dpa);
	doca_dev_close(dev);
	return 0;
}
