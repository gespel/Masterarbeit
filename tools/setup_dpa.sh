#!/bin/bash
# Restores the DPA setup after a reboot or after the partition was destroyed. Safe to run repeatedly.
# 1. DPA EU partition: all 190 EUs for SF mlx5_2 (vhca 101) -> mlx5_0 then has none
# 2. OVS mirror p0 -> en3f0pf0sf0 so outside packets reach the SF
EUMGMT=/opt/mellanox/doca/tools/dpaeumgmt

if sudo $EUMGMT partition query -d mlx5_0 | grep -q "total there are 0"; then
	sudo $EUMGMT partition create -d mlx5_0 --vhca_list 101 --range_eus 0-189 --max_num_eu_group 14
else
	echo "EU partition already exists"
fi

if [ -z "$(sudo ovs-vsctl --columns=name find mirror name=dpa_mirror)" ]; then
	sudo ovs-vsctl -- --id=@p get port p0 -- --id=@sf get port en3f0pf0sf0 \
		-- --id=@m create mirror name=dpa_mirror select-src-port=@p output-port=@sf \
		-- set bridge ovsbr1 mirrors=@m
	echo "OVS mirror created"
else
	echo "OVS mirror already exists"
fi

systemctl is-active -q velox.service && echo "WARNING: velox.service is running, the mirror will see no outside packets"
exit 0
