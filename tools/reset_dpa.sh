#!/bin/bash
# Undoes tools/setup_dpa.sh, e.g. before experiments that run on mlx5_0 (rpc_dpa_bench, flexio_rpc). Safe to run repeatedly.
# 1. Destroys the DPA EU partition -> the EUs go back to mlx5_0
# 2. Removes the OVS mirror p0 -> en3f0pf0sf0
# 3. Removes the test traffic flow (without the mirror it would just drop the test traffic)
EUMGMT=/opt/mellanox/doca/tools/dpaeumgmt
TEST_FLOW="priority=100,in_port=p0,dl_src=a0:88:c2:b6:14:1a,dl_dst=c4:70:bd:a0:56:bc"

if sudo $EUMGMT partition query -d mlx5_0 | grep -q "Partition ID: 1"; then
	sudo $EUMGMT partition destroy -d mlx5_0 --id_partition 1
else
	echo "EU partition does not exist"
fi

if [ -n "$(sudo ovs-vsctl --columns=name find mirror name=dpa_mirror)" ]; then
	sudo ovs-vsctl -- --id=@m get mirror dpa_mirror -- remove bridge ovsbr1 mirrors @m
	echo "OVS mirror removed"
else
	echo "OVS mirror does not exist"
fi

sudo ovs-ofctl del-flows --strict ovsbr1 "$TEST_FLOW"
echo "OVS test traffic flow removed"
exit 0
