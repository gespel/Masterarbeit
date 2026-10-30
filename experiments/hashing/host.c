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

#define Q_DEPTH   (1u << LOG_Q_DEPTH)

extern flexio_func_t pkt_handler;
extern flexio_func_t get_count;
extern flexio_func_t get_hashed;
extern flexio_func_t get_hash_cycles;
extern flexio_func_t hash_tuple;
extern flexio_func_t read_u64;
extern flexio_func_t dump_flows;

static struct flexio_process *proc;

/* Copy a host buffer into newly allocated DPA heap memory. */
static flexio_uintptr_t to_dpa(void *src, size_t len)
{
	flexio_uintptr_t daddr;
	DOCA_TRY(flexio_copy_from_host(proc, src, len, &daddr));
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
	DOCA_TRY(!ctx);
	return ctx;
}

static void steer_all(struct ibv_context *ibv, struct flexio_rq *rq)
{
	struct mlx5dv_flow_match_parameters *match = calloc(1, sizeof(*match) + 64);
	match->match_sz = 64;

	struct mlx5dv_dr_domain *dom = mlx5dv_dr_domain_create(ibv, MLX5DV_DR_DOMAIN_TYPE_NIC_RX);
	DOCA_TRY(!dom);
	struct mlx5dv_dr_table *tbl = mlx5dv_dr_table_create(dom, 0);
	DOCA_TRY(!tbl);
	struct mlx5dv_dr_matcher *matcher = mlx5dv_dr_matcher_create(tbl, 0, 0, match);
	DOCA_TRY(!matcher);
	struct mlx5dv_dr_action *to_rq = mlx5dv_dr_action_create_dest_devx_tir(flexio_rq_get_tir(rq));
	DOCA_TRY(!to_rq);
	DOCA_TRY(!mlx5dv_dr_rule_create(matcher, match, 1, &to_rq));
	free(match);
}

int main(int argc, char **argv) {
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

	struct flexio_msg_stream *stream;
	flexio_msg_stream_attr_t stream_attr = {
		.data_bsize = 4096,
		.sync_mode = FLEXIO_MSG_DEV_SYNC_MODE_SYNC,
		.level = FLEXIO_MSG_DEV_INFO,
	};
	DOCA_TRY(flexio_msg_stream_create(proc, &stream_attr, stdout, NULL, &stream));

	struct flexio_event_handler *eh;
	struct flexio_event_handler_attr eh_attr = {
		.host_stub_func = pkt_handler,
		.affinity.type = FLEXIO_AFFINITY_NONE,
	};
	DOCA_TRY(flexio_event_handler_create(proc, &eh_attr, &eh));

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
	DOCA_TRY(flexio_cq_create(proc, ibv, &cq_attr, &cq));
	ctx.cq_num = flexio_cq_get_cq_num(cq);

	flexio_uintptr_t bufs;
	struct flexio_mkey *mkey;
	DOCA_TRY(flexio_buf_dev_alloc(proc, Q_DEPTH * BUF_BSIZE, &bufs));
	ctx.rx_bufs = bufs; /* the DPA needs this to locate packet data */
	struct flexio_mkey_attr mkey_attr = {
		.pd = pd,
		.daddr = bufs,
		.len = Q_DEPTH * BUF_BSIZE,
		.access = IBV_ACCESS_LOCAL_WRITE,
	};
	DOCA_TRY(flexio_device_mkey_create(proc, &mkey_attr, &mkey));

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
	DOCA_TRY(flexio_rq_create(proc, ibv, ctx.cq_num, &rq_attr, &rq));
	dbr[0] = htobe32(Q_DEPTH); /* receive counter = number of posted WQEs */
	DOCA_TRY(flexio_host2dev_memcpy(proc, dbr, sizeof(dbr), ctx.rq_dbr));

	size_t flows_bsize = (1u << LOG_FLOW_ENTRIES) * sizeof(struct flow);
	DOCA_TRY(flexio_buf_dev_alloc(proc, flows_bsize, &ctx.flows));
	DOCA_TRY(flexio_buf_dev_memset(proc, 0, flows_bsize, ctx.flows));
	struct flexio_heap_mem_info heap;
	DOCA_TRY(flexio_process_mem_info_get(proc, &heap));
	fprintf(stderr, "flow table: %zu MB, heap: size %zu MB, requested %zu MB, allocated %zu MB\n",
		flows_bsize >> 20, heap.size >> 20, heap.requested >> 20, heap.allocated >> 20);

	steer_all(ibv, rq);

	flexio_uintptr_t ctx_daddr = to_dpa(&ctx, sizeof(ctx));
	DOCA_TRY(flexio_event_handler_run(eh, ctx_daddr));
	fprintf(stderr, "hashing the 5-tuple of every IPv4 packet, Ctrl+C to stop\n");

	uint64_t count = 0, hashed = 0, cycles = 0, num_flows = 0;
	while (1) {
		sleep(1);
		DOCA_TRY(flexio_process_call(proc, &get_count, &count, ctx_daddr));
		DOCA_TRY(flexio_process_call(proc, &get_hashed, &hashed, ctx_daddr));
		DOCA_TRY(flexio_process_call(proc, &get_hash_cycles, &cycles, ctx_daddr));
		DOCA_TRY(flexio_process_call(proc, &dump_flows, &num_flows, ctx_daddr));
		fprintf(stderr, "packets: %lu, hashed: %lu, avg cycles/hash: %.1f, num_flows: %lu\n", count, hashed, hashed ? (double)cycles / hashed : 0.0, num_flows);
	}
}
