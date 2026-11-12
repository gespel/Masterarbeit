
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

/* ANSI colors for the stats line */
#define C_GRN "\033[1;32m"
#define C_YEL "\033[1;33m"
#define C_CYN "\033[1;36m"
#define C_RED "\033[1;31m"
#define C_MAG "\033[1;35m"
#define C_RST "\033[0m"

#define Q_DEPTH      (1u << LOG_Q_DEPTH)
#define DPA_HZ       1.8e9
#define EUS_PER_CORE 16
#define NUM_CORES    11
#define NUM_EUS      (NUM_CORES * EUS_PER_CORE)
/* Offset in the outer-header part of the match buffer (PRM fte_match_set_lyr_2_4) */
#define MATCH_IP_PROTOCOL 0x10
/* DevX commands for RSS, the offsets are bytes into the command input (PRM create_rqt_in, create_tir_in) */
#define CMD_ALLOC_TD      0x816
#define CMD_CREATE_TIR    0x900
#define CMD_CREATE_RQT    0x916
#define RQT_SIZE          2048 /* indirection table entries (device limit), so each EU gets 12 or 13 of them */
#define RQT_MAX_SIZE      0x34
#define RQT_ACTUAL_SIZE   0x38
#define RQT_RQ_LIST       0x110
#define TIR_DISP_TYPE     0x24
#define TIR_INDIRECT      0x40 /* rx_hash_symmetric and indirect_table */
#define TIR_HASH          0x44 /* rx_hash_fn and transport_domain */
#define TIR_KEY           0x48
#define TIR_FIELDS        0x70 /* outer rx_hash_field_select: IPv4, TCP, the four bits select IPs and ports */
#define TIR_BSIZE         0x110
#define TIR_DISP_INDIRECT (1u << 28)
#define TIR_SYMMETRIC     (1u << 31)
#define TIR_FN_TOEPLITZ   (2u << 28)
#define TIR_HASH_4_TUPLE  0xf

static struct flexio_process *proc;

extern flexio_func_t pkt_handler;
extern flexio_func_t collect_stats;

static flexio_uintptr_t to_dpa(void *src, size_t len) {
	flexio_uintptr_t daddr;
	DOCA_TRY(flexio_copy_from_host(proc, src, len, &daddr));
	return daddr;
}

static struct ibv_context *open_ibv(const char *name) {
	int num_devices;
	struct ibv_device **list = ibv_get_device_list(&num_devices);
	struct ibv_context *ctx = NULL;

	for (int i = 0; i < num_devices; i++) {
		if (!strcmp(ibv_get_device_name(list[i]), name)) {
			ctx = ibv_open_device(list[i]);
		}
	}
	ibv_free_device_list(list);
	DOCA_TRY(!ctx);
	return ctx;
}

static flexio_uintptr_t create_handler(struct ibv_context *ibv, struct ibv_pd *pd, uint32_t eu, flexio_uintptr_t flows, struct flexio_rq **rq) {
	struct flexio_event_handler *eh;
	struct flexio_event_handler_attr eh_attr = {
		.host_stub_func = pkt_handler,
		.affinity = { .type = FLEXIO_AFFINITY_STRICT, .id = eu },
	};
	DOCA_TRY(flexio_event_handler_create(proc, &eh_attr, &eh));

	struct pkt_ctx ctx = { .flows = flows };
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

	flexio_uintptr_t ctx_daddr = to_dpa(&ctx, sizeof(ctx));
	DOCA_TRY(flexio_event_handler_run(eh, ctx_daddr));
	return ctx_daddr;
}

static uint32_t devx_create(struct ibv_context *ibv, const void *in, size_t inlen, struct mlx5dv_devx_obj **obj) {
	uint32_t out[4] = {0};

	*obj = mlx5dv_devx_obj_create(ibv, in, inlen, out, sizeof(out));
	DOCA_TRY(!*obj);
	return be32toh(out[2]) & 0xffffff;
}

static struct mlx5dv_devx_obj *create_rss_tir(struct ibv_context *ibv, const uint32_t *rqn) {
	static const uint8_t key[40] = {
		0x6d, 0x5a, 0x56, 0xda, 0x25, 0x5b, 0x0e, 0xc2, 0x41, 0x67, 0x25, 0x3d, 0x43, 0xa3, 0x8f, 0xb0,
		0xd0, 0xca, 0x2b, 0xcb, 0xae, 0x7b, 0x30, 0xb4, 0x77, 0xcb, 0x2d, 0xa3, 0x80, 0x30, 0xf2, 0x0c,
		0x6a, 0x42, 0xb7, 0x3b, 0xbe, 0xac, 0x01, 0xfa,
	};
	struct mlx5dv_devx_obj *obj;

	uint32_t td_in[4] = { htobe32(CMD_ALLOC_TD << 16) };
	uint32_t td = devx_create(ibv, td_in, sizeof(td_in), &obj);

	size_t rqt_bsize = RQT_RQ_LIST + RQT_SIZE * sizeof(uint32_t);
	uint32_t *rqt_in = calloc(1, rqt_bsize);
	DOCA_TRY(!rqt_in);
	rqt_in[0] = htobe32(CMD_CREATE_RQT << 16);
	rqt_in[RQT_MAX_SIZE / 4] = htobe32(RQT_SIZE);
	rqt_in[RQT_ACTUAL_SIZE / 4] = htobe32(RQT_SIZE);
	for (uint32_t i = 0; i < RQT_SIZE; i++)
		rqt_in[RQT_RQ_LIST / 4 + i] = htobe32(rqn[i % NUM_EUS]);
	uint32_t rqt = devx_create(ibv, rqt_in, rqt_bsize, &obj);
	free(rqt_in);

	uint32_t tir_in[TIR_BSIZE / 4] = { htobe32(CMD_CREATE_TIR << 16) };
	tir_in[TIR_DISP_TYPE / 4] = htobe32(TIR_DISP_INDIRECT);
	tir_in[TIR_INDIRECT / 4] = htobe32(TIR_SYMMETRIC | rqt);
	tir_in[TIR_HASH / 4] = htobe32(TIR_FN_TOEPLITZ | td);
	memcpy(&tir_in[TIR_KEY / 4], key, sizeof(key));
	tir_in[TIR_FIELDS / 4] = htobe32(TIR_HASH_4_TUPLE);
	devx_create(ibv, tir_in, sizeof(tir_in), &obj);
	return obj;
}

static void steer_flows(struct ibv_context *ibv, struct ibv_pd *pd, flexio_uintptr_t *ctx) {
	struct flexio_rq *rq[NUM_EUS];
	uint32_t rqn[NUM_EUS];

	size_t eu_flows_bsize = (1u << LOG_FLOW_ENTRIES) * sizeof(struct flow);
	size_t flows_bsize = NUM_EUS * eu_flows_bsize;
	flexio_uintptr_t flows;
	DOCA_TRY(flexio_buf_dev_alloc(proc, flows_bsize, &flows));
	DOCA_TRY(flexio_buf_dev_memset(proc, 0, flows_bsize, flows));

	for (unsigned int eu = 0; eu < NUM_EUS; eu++) {
		ctx[eu] = create_handler(ibv, pd, eu, flows + eu * eu_flows_bsize, &rq[eu]);
		rqn[eu] = flexio_rq_get_wq_num(rq[eu]);
		DOCA_TRY(rqn[eu] == UINT32_MAX);
	}

	struct mlx5dv_dr_action *to_eu0 = mlx5dv_dr_action_create_dest_devx_tir(flexio_rq_get_tir(rq[0]));
	DOCA_TRY(!to_eu0);
	struct mlx5dv_dr_action *to_rss = mlx5dv_dr_action_create_dest_devx_tir(create_rss_tir(ibv, rqn));
	DOCA_TRY(!to_rss);

	struct mlx5dv_flow_match_parameters *match = calloc(1, sizeof(*match) + 64);
	uint8_t *m = (uint8_t *)match->match_buf;
	match->match_sz = 64;

	struct mlx5dv_dr_domain *dom = mlx5dv_dr_domain_create(ibv, MLX5DV_DR_DOMAIN_TYPE_NIC_RX);
	DOCA_TRY(!dom);
	struct mlx5dv_dr_table *tbl = mlx5dv_dr_table_create(dom, 0);
	DOCA_TRY(!tbl);
	struct mlx5dv_dr_matcher *rest = mlx5dv_dr_matcher_create(tbl, 1, 0, match); /* match all, lower priority */
	DOCA_TRY(!rest);
	DOCA_TRY(!mlx5dv_dr_rule_create(rest, match, 1, &to_eu0));

	m[MATCH_IP_PROTOCOL] = 0xff;
	struct mlx5dv_dr_matcher *tcp = mlx5dv_dr_matcher_create(tbl, 0, 1, match); /* 1 = outer headers */
	DOCA_TRY(!tcp);

	m[MATCH_IP_PROTOCOL] = IPPROTO_TCP;
	DOCA_TRY(!mlx5dv_dr_rule_create(tcp, match, 1, &to_rss));
	free(match);
}

int main() {
	struct ibv_context *ibv = open_ibv("mlx5_2");
	struct ibv_pd *pd = ibv_alloc_pd(ibv);
	DOCA_TRY(!pd);

	struct flexio_app *app;
	struct flexio_app_select_attr sel = {
		.app_name = "huginn_app", 
		.hw_model_id = FLEXIO_HW_MODEL_DEF, 
		.ibv_ctx = ibv,
	};

	struct flexio_msg_stream *stream;
	
	flexio_msg_stream_attr_t stream_attr = {
		.data_bsize = 4096, 
		.sync_mode = FLEXIO_MSG_DEV_SYNC_MODE_SYNC, 
		.level = FLEXIO_MSG_DEV_INFO,
	};

	DOCA_TRY(flexio_version_set(FLEXIO_VER_USED));
	DOCA_TRY(flexio_app_get(&sel, &app));
	DOCA_TRY(flexio_process_create(ibv, app, NULL, &proc));

	DOCA_TRY(flexio_msg_stream_create(proc, &stream_attr, stdout, NULL, &stream));

	flexio_uintptr_t ctx[NUM_EUS];
	steer_flows(ibv, pd, ctx);

	flexio_uintptr_t ctxs = to_dpa(ctx, sizeof(ctx));
	flexio_uintptr_t st_daddr;
	DOCA_TRY(flexio_buf_dev_alloc(proc, sizeof(struct stats), &st_daddr));
	struct stats st;
	struct flexio_mem st_src = { .mem_type = FLEXIO_MEMTYPE_DPA, .daddr = st_daddr };
	struct flexio_mem st_dst = { .mem_type = FLEXIO_MEMTYPE_HOST, .haddr = (uintptr_t)&st };

	struct timespec t0, now;
	clock_gettime(CLOCK_MONOTONIC, &t0);
	uint64_t last = 0, last_coll = 0, last_inferred = 0, last_mal = 0;
	double last_t = 0;
	int duration = 0;
	while (1) {
		usleep(500000);
		//system("clear");
		flexio_msg_stream_flush(stream);

		uint64_t ret;
		DOCA_TRY(flexio_process_call(proc, &collect_stats, &ret, ctxs, (uint64_t)NUM_EUS, st_daddr));
		DOCA_TRY(flexio_memcpy(proc, &st_src, &st_dst, sizeof(st)));
		clock_gettime(CLOCK_MONOTONIC, &now);
		double t = (now.tv_sec - t0.tv_sec) + (now.tv_nsec - t0.tv_nsec) * 1e-9;
		uint64_t count = st.count, cycles = st.cycles, used = st.used, coll = st.collisions, inferred = st.inferred, mal = st.malicious;
		double coll_pct = count > last ? 100.0 * (coll - last_coll) / (count - last) : 0.0;
		double mal_pct = inferred > last_inferred ? 100.0 * (mal - last_mal) / (inferred - last_inferred) : 0.0;
		/*fprintf(stdout, "million pkt/s: %.2f, cycles/pkt: %.1f, flow table: %lu/%u (%.1f%%), collisions: %.3f%%\n",
			((count - last) / (t - last_t)) / 1000000, count ? (double)cycles / count : 0.0,
			used, 1u << LOG_FLOW_ENTRIES, 100.0 * used / (1u << LOG_FLOW_ENTRIES), coll_pct);*/
		fprintf(stderr, 
				"million pkt/s: " C_GRN "%.2f" C_RST
				", cycles/pkt: " C_YEL "%.1f" C_RST
				", flow table: " C_CYN "%lu/%u (%.1f%%)" C_RST
				", collisions: " C_RED "%.3f%%" C_RST
				", inferred: " C_MAG "%f" C_RST " million flows/s\n",
			((count - last) / (t - last_t)) / 1000000, 
			count ? (double)cycles / count : 0.0,
			used, 
			NUM_EUS << LOG_FLOW_ENTRIES,
			100.0 * used / (NUM_EUS << LOG_FLOW_ENTRIES),
			coll_pct, 
			(inferred - last_inferred) / (t - last_t) / 1000000
		);
		last = count;
		last_coll = coll;
		last_t = t;
		last_inferred = inferred;
		last_mal = mal;
		//duration += 1;
		//if (duration >= 30) {
		//	break;
		//}
	}
}
