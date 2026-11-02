/*
 * ./hashing [core]: one pkt_handler per EU of a DPA core, TCP packets spread over them by source port.
 * Prints the measured handler cycles per packet and extrapolates the packet rate of the whole core.
 */
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

#define DOCA_TRY(x) do { if (x) { fprintf(stderr, "%s failed\n", #x); exit(1); } } while (0)

#define Q_DEPTH      (1u << LOG_Q_DEPTH)
#define DPA_HZ       1.8e9
#define EUS_PER_CORE 16
/* Offsets in the outer-header part of the match buffer (PRM fte_match_set_lyr_2_4) */
#define MATCH_IP_PROTOCOL 0x10
#define MATCH_TCP_SPORT   0x14

extern flexio_func_t pkt_handler;
extern flexio_func_t read_u64;

static struct flexio_process *proc;

/* Copy a host buffer into newly allocated DPA heap memory. */
static flexio_uintptr_t to_dpa(void *src, size_t len)
{
	flexio_uintptr_t daddr;
	DOCA_TRY(flexio_copy_from_host(proc, src, len, &daddr));
	return daddr;
}

static uint64_t dpa_u64(flexio_uintptr_t daddr)
{
	uint64_t v;
	DOCA_TRY(flexio_process_call(proc, &read_u64, &v, daddr));
	return v;
}

static struct ibv_context *open_ibv(const char *name)
{
	struct ibv_device **list = ibv_get_device_list(NULL);
	struct ibv_context *ctx = NULL;

	for (int i = 0; list && list[i] && !ctx; i++)
		if (!strcmp(ibv_get_device_name(list[i]), name))
			ctx = ibv_open_device(list[i]);
	ibv_free_device_list(list);
	DOCA_TRY(!ctx);
	return ctx;
}

/* pkt_handler pinned to EU eu with its own CQ, RQ, RX buffers and flow table; returns the DPA address of its pkt_ctx. */
static flexio_uintptr_t create_handler(struct ibv_context *ibv, struct ibv_pd *pd, uint32_t eu, struct flexio_rq **rq)
{
	struct flexio_event_handler *eh;
	struct flexio_event_handler_attr eh_attr = {
		.host_stub_func = pkt_handler,
		.affinity = { .type = FLEXIO_AFFINITY_STRICT, .id = eu },
	};
	DOCA_TRY(flexio_event_handler_create(proc, &eh_attr, &eh));

	struct pkt_ctx ctx = {0};
	struct mlx5_cqe64 cqes[Q_DEPTH] = {0};
	__be32 dbr[2] = {0, 0};
	for (uint32_t i = 0; i < Q_DEPTH; i++)
		mlx5dv_set_cqe_owner(&cqes[i], 1);
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
	DOCA_TRY(flexio_cq_create(proc, ibv, &cq_attr, &cq));
	ctx.cq_num = flexio_cq_get_cq_num(cq);

	struct flexio_mkey *mkey;
	DOCA_TRY(flexio_buf_dev_alloc(proc, Q_DEPTH * BUF_BSIZE, &ctx.rx_bufs));
	struct flexio_mkey_attr mkey_attr = {
		.pd = pd,
		.daddr = ctx.rx_bufs,
		.len = Q_DEPTH * BUF_BSIZE,
		.access = IBV_ACCESS_LOCAL_WRITE,
	};
	DOCA_TRY(flexio_device_mkey_create(proc, &mkey_attr, &mkey));

	struct mlx5_wqe_data_seg wqes[Q_DEPTH];
	for (uint32_t i = 0; i < Q_DEPTH; i++)
		mlx5dv_set_data_seg(&wqes[i], BUF_BSIZE, flexio_mkey_get_id(mkey), ctx.rx_bufs + i * BUF_BSIZE);
	ctx.rq_dbr = to_dpa(dbr, sizeof(dbr));

	struct flexio_wq_attr rq_attr = {
		.log_wq_depth = LOG_Q_DEPTH,
		.pd = pd,
		.wq_dbr_qmem = { .memtype = FLEXIO_MEMTYPE_DPA, .daddr = ctx.rq_dbr },
		.wq_ring_qmem.daddr = to_dpa(wqes, sizeof(wqes)),
	};
	DOCA_TRY(flexio_rq_create(proc, ibv, ctx.cq_num, &rq_attr, rq));
	dbr[0] = htobe32(Q_DEPTH); /* receive counter = number of posted WQEs */
	DOCA_TRY(flexio_host2dev_memcpy(proc, dbr, sizeof(dbr), ctx.rq_dbr));

	size_t flows_bsize = (1u << LOG_FLOW_ENTRIES) * sizeof(struct flow);
	DOCA_TRY(flexio_buf_dev_alloc(proc, flows_bsize, &ctx.flows));
	DOCA_TRY(flexio_buf_dev_memset(proc, 0, flows_bsize, ctx.flows));

	flexio_uintptr_t ctx_daddr = to_dpa(&ctx, sizeof(ctx));
	DOCA_TRY(flexio_event_handler_run(eh, ctx_daddr));
	return ctx_daddr;
}

/* TCP goes to rqs[low 4 bits of the source port], all other packets to rqs[0]. */
static void steer_by_port(struct ibv_context *ibv, struct flexio_rq **rqs)
{
	struct mlx5dv_flow_match_parameters *match = calloc(1, sizeof(*match) + 64);
	uint8_t *m = (uint8_t *)match->match_buf;
	match->match_sz = 64;

	struct mlx5dv_dr_domain *dom = mlx5dv_dr_domain_create(ibv, MLX5DV_DR_DOMAIN_TYPE_NIC_RX);
	DOCA_TRY(!dom);
	struct mlx5dv_dr_table *tbl = mlx5dv_dr_table_create(dom, 0);
	DOCA_TRY(!tbl);
	struct mlx5dv_dr_matcher *rest = mlx5dv_dr_matcher_create(tbl, 1, 0, match); /* match all, lower priority */
	DOCA_TRY(!rest);
	m[MATCH_IP_PROTOCOL] = 0xff;
	m[MATCH_TCP_SPORT + 1] = EUS_PER_CORE - 1;
	struct mlx5dv_dr_matcher *by_port = mlx5dv_dr_matcher_create(tbl, 0, 1, match); /* 1 = outer headers */
	DOCA_TRY(!by_port);

	for (unsigned int i = 0; i < EUS_PER_CORE; i++) {
		struct mlx5dv_dr_action *to_rq = mlx5dv_dr_action_create_dest_devx_tir(flexio_rq_get_tir(rqs[i]));
		DOCA_TRY(!to_rq);
		m[MATCH_IP_PROTOCOL] = IPPROTO_TCP;
		m[MATCH_TCP_SPORT + 1] = i;
		DOCA_TRY(!mlx5dv_dr_rule_create(by_port, match, 1, &to_rq));
		if (i == 0) {
			memset(m, 0, 64);
			DOCA_TRY(!mlx5dv_dr_rule_create(rest, match, 1, &to_rq));
		}
	}
	free(match);
}

int main(int argc, char **argv) {
	unsigned int core = argc > 1 ? atoi(argv[1]) : 0;
	struct ibv_context *ibv = open_ibv("mlx5_2");
	struct ibv_pd *pd = ibv_alloc_pd(ibv);
	DOCA_TRY(!pd);

	struct flexio_app *app;
	struct flexio_app_select_attr sel = {
		.app_name = "hashing_app",
		.hw_model_id = FLEXIO_HW_MODEL_DEF,
		.ibv_ctx = ibv,
	};
	DOCA_TRY(flexio_version_set(FLEXIO_VER_USED));
	DOCA_TRY(flexio_app_get(&sel, &app));
	DOCA_TRY(flexio_process_create(ibv, app, NULL, &proc));

	flexio_uintptr_t ctx[EUS_PER_CORE];
	struct flexio_rq *rqs[EUS_PER_CORE];
	for (unsigned int i = 0; i < EUS_PER_CORE; i++)
		ctx[i] = create_handler(ibv, pd, core * EUS_PER_CORE + i, &rqs[i]);
	steer_by_port(ibv, rqs);
	fprintf(stderr, "pkt_handler on EUs %u..%u, Ctrl+C to stop\n", core * EUS_PER_CORE, core * EUS_PER_CORE + EUS_PER_CORE - 1);

	/* stdout: CSV with the cumulative counters of every EU once per second, stderr: summary */
	//printf("t_s,eu,count,cycles\n");
	struct timespec t0, now;
	clock_gettime(CLOCK_MONOTONIC, &t0);
	uint64_t last = 0;
	double last_t = 0;
	while (1) {
		uint64_t count = 0, cycles = 0, n, c;

		sleep(1);
		/* the RPCs below take time too, so stamp every interval with the real time */
		clock_gettime(CLOCK_MONOTONIC, &now);
		double t = (now.tv_sec - t0.tv_sec) + (now.tv_nsec - t0.tv_nsec) * 1e-9;
		for (unsigned int i = 0; i < EUS_PER_CORE; i++) {
			n = dpa_u64(ctx[i] + offsetof(struct pkt_ctx, count));
			c = dpa_u64(ctx[i] + offsetof(struct pkt_ctx, cycles));
			//printf("%.3f,%u,%lu,%lu\n", t, i, n, c);
			count += n;
			cycles += c;
		}
		//fflush(stdout);
		double cpp = count ? (double)cycles / count : 0.0; /* handler cycles per packet, all EUs */
		fprintf(stderr, "pkt/s: %.0f, cycles/pkt: %.1f, extrapolated: %.0f pkt/s per EU, %.0f pkt/s per core\n",
			(count - last) / (t - last_t), cpp, cpp ? DPA_HZ / cpp : 0.0, cpp ? EUS_PER_CORE * DPA_HZ / cpp : 0.0);
		last = count;
		last_t = t;
	}
}
