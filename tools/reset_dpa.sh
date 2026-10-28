#!/bin/bash
# Undoes tools/setup_dpa.sh, e.g. before experiments that run on mlx5_0 (rpc_dpa_bench, flexio_rpc). Safe to run repeatedly.
# 1. Destroys the DPA EU partition -> the EUs go back to mlx5_0
# 2. Removes the OVS mirror p0 -> en3f0pf0sf0
EUMGMT=/opt/mellanox/doca/tools/dpaeumgmt

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
exit 0
