#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <infiniband/mlx5dv.h>
#include <libflexio/flexio_ver.h>
#define FLEXIO_VER_USED FLEXIO_VER(26, 4, 0)
#include <libflexio/flexio.h>
#include "common.h"

#define TRY(x) do { if (x) { fprintf(stderr, "%s failed\n", #x); exit(1); } } while (0)

#define Q_DEPTH   (1u << LOG_Q_DEPTH)

extern flexio_func_t pkt_handler;
extern flexio_func_t get_count;
extern flexio_func_t get_hashed;
extern flexio_func_t get_hash_cycles;
extern flexio_func_t hash_tuple;
extern flexio_func_t hash_bench;
extern flexio_func_t read_u64;

static struct flexio_process *proc;

/* Copy a host buffer into newly allocated DPA heap memory. */
static flexio_uintptr_t to_dpa(void *src, size_t len)
{
	flexio_uintptr_t daddr;
	TRY(flexio_copy_from_host(proc, src, len, &daddr));
	return daddr;
}

static struct ibv_context *open_ibv(const char *name)
{
	struct ibv_device **list = ibv_get_device_list(NULL);
	struct ibv_context *ctx = NULL;

	for (int i = 0; list && list[i] && !ctx; i++)
		if (!strcmp(ibv_get_device_name(list[i]), name))
			ctx = ibv_open_device(list[i]);
	ibv_free_device_list(list);
	TRY(!ctx);
	return ctx;
}

/* Steer all incoming packets into the RQ (all-zero mask matches everything). */
static void steer_all(struct ibv_context *ibv, struct flexio_rq *rq)
{
	struct mlx5dv_flow_match_parameters *match = calloc(1, sizeof(*match) + 64);
	match->match_sz = 64;

	struct mlx5dv_dr_domain *dom = mlx5dv_dr_domain_create(ibv, MLX5DV_DR_DOMAIN_TYPE_NIC_RX);
	TRY(!dom);
	struct mlx5dv_dr_table *tbl = mlx5dv_dr_table_create(dom, 0);
	TRY(!tbl);
	struct mlx5dv_dr_matcher *matcher = mlx5dv_dr_matcher_create(tbl, 0, 0, match);
	TRY(!matcher);
	struct mlx5dv_dr_action *to_rq = mlx5dv_dr_action_create_dest_devx_tir(flexio_rq_get_tir(rq));
	TRY(!to_rq);
	TRY(!mlx5dv_dr_rule_create(matcher, match, 1, &to_rq));
	free(match);
}

/* Hash a few tuples on the DPA and on the host; both run the same flow_hash() from common.h. */
static void self_test(void)
{
	const struct five_tuple tests[] = {
		{ 0x0a000001, 0x0a000002, 12345, 80,   6  }, /* 10.0.0.1:12345 -> 10.0.0.2:80, TCP */
		{ 0x0a000002, 0x0a000001, 80,    12345, 6 }, /* reverse direction must give a different hash */
		{ 0xc0a80101, 0x08080808, 53000, 53,   17 }, /* 192.168.1.1 -> 8.8.8.8, UDP DNS */
		{ 0xc0a80101, 0x08080808, 0,     0,    1  }, /* ICMP, no ports */
	};

	for (size_t i = 0; i < sizeof(tests) / sizeof(tests[0]); i++) {
		const struct five_tuple *t = &tests[i];
		uint64_t dpa;
		uint32_t host = flow_hash(t);
		TRY(flexio_process_call(proc, &hash_tuple, &dpa, (uint64_t)t->src_ip, (uint64_t)t->dst_ip,
					((uint64_t)t->src_port << 16) | t->dst_port, (uint64_t)t->proto));
		fprintf(stderr, "self-test %zu: host=0x%08x dpa=0x%08lx %s\n", i, host, dpa, host == dpa ? "ok" : "MISMATCH");
		TRY(host != dpa);
	}
}

/* One hash_bench() run of n hashes on the DPA, result read back via RPC. */
static void bench_run(flexio_uintptr_t res_daddr, uint64_t n, struct bench_res *res)
{
	uint64_t unused;
	TRY(flexio_process_call(proc, &hash_bench, &unused, res_daddr, n));
	TRY(flexio_process_call(proc, &read_u64, &res->cycles, res_daddr + offsetof(struct bench_res, cycles)));
	TRY(flexio_process_call(proc, &read_u64, &res->us, res_daddr + offsetof(struct bench_res, us)));
}

/* Max hash rate of one DPA thread: 10 runs per n from 1e3 to 1e8.
 * 1e9 (~35 s) does not work, flexio_process_call() runs into its RPC polling timeout.
 * Prints CSV to stdout. */
static void bench(void)
{
	struct bench_res res = {0};
	flexio_uintptr_t res_daddr = to_dpa(&res, sizeof(res));

	printf("n,run,cycles,us\n");
	for (uint64_t n = 1000; n <= 100000000; n *= 10) {
		for (int run = 0; run < 10; run++) {
			bench_run(res_daddr, n, &res);
			printf("%lu,%d,%lu,%lu\n", n, run, res.cycles, res.us);
			fflush(stdout);
		}
	}
}

/* Long-term stability: back-to-back runs of 1e7 hashes (~0.3 s each) for the given number of seconds.
 * Prints CSV to stdout, t_s = host time since start. */
static void stability(int seconds)
{
	struct bench_res res = {0};
	flexio_uintptr_t res_daddr = to_dpa(&res, sizeof(res));
	const uint64_t n = 10000000;
	struct timespec t0, t;

	printf("t_s,n,cycles,us\n");
	clock_gettime(CLOCK_MONOTONIC, &t0);
	do {
		bench_run(res_daddr, n, &res);
		clock_gettime(CLOCK_MONOTONIC, &t);
		printf("%.3f,%lu,%lu,%lu\n", (t.tv_sec - t0.tv_sec) + (t.tv_nsec - t0.tv_nsec) / 1e9, n, res.cycles, res.us);
		fflush(stdout);
	} while (t.tv_sec - t0.tv_sec < seconds);
}

/* Print the per-packet log (hash and cycles of the first n hashed packets) as CSV to stdout. */
static void dump_log(flexio_uintptr_t log_daddr, uint64_t n)
{
	printf("idx,hash,cycles\n");
	for (uint64_t i = 0; i < n && i < LOG_ENTRIES; i++) {
		uint64_t e;
		TRY(flexio_process_call(proc, &read_u64, &e, log_daddr + i * sizeof(uint64_t)));
		printf("%lu,0x%08lx,%lu\n", i, e & 0xffffffff, e >> 32);
	}
}

int main(int argc, char **argv)
{
	/* Process and queues all live on the SF. The SF needs its own DPA EU partition (check: dpaeumgmt partition query -d mlx5_0):
	 * sudo dpaeumgmt partition create -d mlx5_0 --vhca_list 101 --range_eus 0-189 --max_num_eu_group 14 */
	const char *dev = argc > 1 ? argv[1] : "mlx5_2"; /* SF that receives the OVS mirror copies */
	struct ibv_context *ibv = open_ibv(dev);
	struct ibv_pd *pd = ibv_alloc_pd(ibv);
	TRY(!pd);

	/* Load the DPA program */
	struct flexio_app *app;
	struct flexio_app_select_attr sel = {
		.app_name = "hashing_app",
		.hw_model_id = FLEXIO_HW_MODEL_DEF,
		.ibv_ctx = ibv,
	};
	TRY(flexio_version_set(FLEXIO_VER_USED));
	TRY(flexio_app_get(&sel, &app));
	TRY(flexio_process_create(ibv, app, NULL, &proc));

	/* Forward flexio_dev_print() output to stdout */
	struct flexio_msg_stream *stream;
	flexio_msg_stream_attr_t stream_attr = {
		.data_bsize = 4096,
		.sync_mode = FLEXIO_MSG_DEV_SYNC_MODE_SYNC,
		.level = FLEXIO_MSG_DEV_INFO,
	};
	TRY(flexio_msg_stream_create(proc, &stream_attr, stdout, NULL, &stream));

	/* Modes: ./hashing <dev>                 receive and hash packets until Ctrl+C
	 *        ./hashing <dev> bench           throughput benchmark, no packets
	 *        ./hashing <dev> stability <s>   back-to-back benchmark runs for s seconds
	 *        ./hashing <dev> log <n>         receive until n packets are hashed, then dump the per-packet log
	 * CSV goes to stdout, everything else to stderr. */
	const char *mode = argc > 2 ? argv[2] : "";
	uint64_t log_n = !strcmp(mode, "log") && argc > 3 ? strtoull(argv[3], NULL, 0) : 0;

	self_test();
	if (!strcmp(mode, "bench")) {
		bench();
		return 0;
	}
	if (!strcmp(mode, "stability")) {
		stability(argc > 3 ? atoi(argv[3]) : 120);
		return 0;
	}

	/* Event handler: a DPA thread that runs pkt_handler on every CQ event */
	struct flexio_event_handler *eh;
	struct flexio_event_handler_attr eh_attr = {
		.host_stub_func = pkt_handler,
		.affinity.type = FLEXIO_AFFINITY_NONE,
	};
	TRY(flexio_event_handler_create(proc, &eh_attr, &eh));

	/* CQ bound to the handler thread, all CQEs start HW-owned */
	struct pkt_ctx ctx = {0};
	struct mlx5_cqe64 cqes[Q_DEPTH] = {0};
	__be32 dbr[2] = {0, 0};
	for (uint32_t i = 0; i < Q_DEPTH; i++) {
		mlx5dv_set_cqe_owner(&cqes[i], 1);
	}
	ctx.cq_ring = to_dpa(cqes, sizeof(cqes));
	ctx.cq_dbr = to_dpa(dbr, sizeof(dbr));

	struct flexio_cq *cq;
	struct flexio_cq_attr cq_attr = {
		.log_cq_depth = LOG_Q_DEPTH,
		.element_type = FLEXIO_CQ_ELEMENT_TYPE_DPA_THREAD,
		.thread = flexio_event_handler_get_thread(eh),
		.uar_id = flexio_uar_get_id(flexio_process_get_uar(proc)),
		.cq_dbr_daddr = ctx.cq_dbr,
		.cq_ring_qmem.daddr = ctx.cq_ring,
	};
	TRY(flexio_cq_create(proc, ibv, &cq_attr, &cq));
	ctx.cq_num = flexio_cq_get_cq_num(cq);

	/* RQ with one pre-posted WQE per RX buffer */
	flexio_uintptr_t bufs;
	struct flexio_mkey *mkey;
	TRY(flexio_buf_dev_alloc(proc, Q_DEPTH * BUF_BSIZE, &bufs));
	ctx.rx_bufs = bufs; /* the DPA needs this to locate packet data */
	TRY(flexio_buf_dev_alloc(proc, LOG_ENTRIES * sizeof(uint64_t), &ctx.pkt_log));
	struct flexio_mkey_attr mkey_attr = {
		.pd = pd,
		.daddr = bufs,
		.len = Q_DEPTH * BUF_BSIZE,
		.access = IBV_ACCESS_LOCAL_WRITE,
	};
	TRY(flexio_device_mkey_create(proc, &mkey_attr, &mkey));

	struct mlx5_wqe_data_seg wqes[Q_DEPTH];
	for (uint32_t i = 0; i < Q_DEPTH; i++) {
		mlx5dv_set_data_seg(&wqes[i], BUF_BSIZE, flexio_mkey_get_id(mkey), bufs + i * BUF_BSIZE);
	}
	ctx.rq_dbr = to_dpa(dbr, sizeof(dbr));

	struct flexio_rq *rq;
	struct flexio_wq_attr rq_attr = {
		.log_wq_depth = LOG_Q_DEPTH,
		.pd = pd,
		.wq_dbr_qmem = { .memtype = FLEXIO_MEMTYPE_DPA, .daddr = ctx.rq_dbr },
		.wq_ring_qmem.daddr = to_dpa(wqes, sizeof(wqes)),
	};
	TRY(flexio_rq_create(proc, ibv, ctx.cq_num, &rq_attr, &rq));
	dbr[0] = htobe32(Q_DEPTH); /* receive counter = number of posted WQEs */
	TRY(flexio_host2dev_memcpy(proc, dbr, sizeof(dbr), ctx.rq_dbr));

	steer_all(ibv, rq); /* only mirror copies arrive on the SF, so match-all is safe here */

	/* Hand the context to the DPA and start; the counters are polled via RPC */
	flexio_uintptr_t ctx_daddr = to_dpa(&ctx, sizeof(ctx));
	TRY(flexio_event_handler_run(eh, ctx_daddr));
	fprintf(stderr, "hashing the 5-tuple of every IPv4 packet on %s, Ctrl+C to stop\n", dev);

	uint64_t count = 0, hashed = 0, cycles = 0;
	while (1) {
		sleep(1);
		TRY(flexio_process_call(proc, &get_count, &count, ctx_daddr));
		TRY(flexio_process_call(proc, &get_hashed, &hashed, ctx_daddr));
		TRY(flexio_process_call(proc, &get_hash_cycles, &cycles, ctx_daddr));
		fprintf(stderr, "packets: %lu, hashed: %lu, avg cycles/hash: %.1f\n",
			count, hashed, hashed ? (double)cycles / hashed : 0.0);
		if (log_n && hashed >= log_n) {
			dump_log(ctx.pkt_log, log_n);
			return 0;
		}
	}
	/* on exit the kernel releases all DPA/device resources */
}
