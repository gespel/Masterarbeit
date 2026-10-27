#!/bin/bash
# All measurements for auswertung.ipynb, one after the other so the DPA is otherwise idle (~5 min).
# Needs the SF EU partition (see host.c) and sudo.
set -e
cd "$(dirname "$0")"
mkdir -p results

echo "1/3 throughput benchmark"
sudo ./hashing mlx5_2 bench > results/bench.csv

echo "2/3 stability, 120 s"
sudo ./hashing mlx5_2 stability 120 > results/stability.csv

echo "3/3 packet path, 20000 flows + 2000 repeats"
sudo ./hashing mlx5_2 log 22000 > results/pkts.csv &
sleep 3
sudo python3 -I inject.py en3f0pf0sf0 20000 2000 results/sent.csv 0.001
wait
echo done
