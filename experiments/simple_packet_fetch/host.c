#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
extern flexio_func_t get_ipv4;

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

int main(int argc, char **argv)
{
	if (argc != 2) {
		fprintf(stderr, "usage: %s <mlx5 device>\n", argv[0]);
		return 1;
	}
	struct ibv_context *ibv = open_ibv(argv[1]);

	/* Load the DPA program */
	struct flexio_app *app;
	struct flexio_app_select_attr sel = {
		.app_name = "pkt_count_app", 
		.hw_model_id = FLEXIO_HW_MODEL_DEF, 
		.ibv_ctx = ibv,
	};
	TRY(flexio_version_set(FLEXIO_VER_USED));
	TRY(flexio_app_get(&sel, &app));
	TRY(flexio_process_create(ibv, app, NULL, &proc));
	struct ibv_pd *pd = flexio_process_get_pd(proc);

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
	TRY(flexio_cq_create(proc, NULL, &cq_attr, &cq));
	ctx.cq_num = flexio_cq_get_cq_num(cq);

	/* RQ with one pre-posted WQE per RX buffer */
	flexio_uintptr_t bufs;
	struct flexio_mkey *mkey;
	TRY(flexio_buf_dev_alloc(proc, Q_DEPTH * BUF_BSIZE, &bufs));
	ctx.rx_bufs = bufs; /* the DPA needs this to locate packet data */
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
	TRY(flexio_rq_create(proc, NULL, ctx.cq_num, &rq_attr, &rq));
	dbr[0] = htobe32(Q_DEPTH); /* receive counter = number of posted WQEs */
	TRY(flexio_host2dev_memcpy(proc, dbr, sizeof(dbr), ctx.rq_dbr));

	steer_all(ibv, rq);

	/* Hand the context to the DPA and start; the counter is polled via RPC */
	flexio_uintptr_t ctx_daddr = to_dpa(&ctx, sizeof(ctx));
	TRY(flexio_event_handler_run(eh, ctx_daddr));
	printf("counting all packets on %s, Ctrl+C to stop\n", argv[1]);

	uint64_t count = 0, ipv4 = 0;
	while(1) {
		sleep(1);
		TRY(flexio_process_call(proc, &get_count, &count, ctx_daddr));
		TRY(flexio_process_call(proc, &get_ipv4, &ipv4, ctx_daddr));
		printf("packets: %lu (IPv4: %lu)\n", count, ipv4);
		fflush(stdout);
	}
	/* never reached: on exit the kernel releases all DPA/device resources */
}
