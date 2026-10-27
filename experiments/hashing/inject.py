"""Send IPv4 TCP/UDP frames with random 5-tuples to the SF and log what was sent.

Frames go out on the SF representor, so they arrive only at the SF (mlx5_2), nothing reaches the wire.
Usage: sudo python3 -I inject.py <iface> <n_flows> <n_repeat> <sent.csv> [gap_s, default 0.002]
Every flow is sent once, then the first n_repeat flows are sent again (same tuple must give the same hash).
"""
import csv
import random
import socket
import struct
import sys
import time

SF_MAC = bytes.fromhex("0292d9857ff8")   # MAC of enp3s0f0s0 (the SF netdev)
SRC_MAC = bytes.fromhex("020000000001")


def csum(b):
    t = sum(struct.unpack("!10H", b))
    t = (t >> 16) + (t & 0xFFFF)
    return ~(t + (t >> 16)) & 0xFFFF


def frame(src_ip, dst_ip, src_port, dst_port, proto, ident):
    if proto == 17:
        l4 = struct.pack("!HHHH", src_port, dst_port, 8 + 18, 0) + b"x" * 18
    else:  # TCP header with SYN, no checksum (the DPA does not check it)
        l4 = struct.pack("!HHIIBBHHH", src_port, dst_port, 0, 0, 5 << 4, 0x02, 1024, 0, 0)
    ip = struct.pack("!BBHHHBBH4s4s", 0x45, 0, 20 + len(l4), ident & 0xFFFF, 0, 64, proto, 0,
                     struct.pack("!I", src_ip), struct.pack("!I", dst_ip))
    ip = ip[:10] + struct.pack("!H", csum(ip)) + ip[12:]
    return SF_MAC + SRC_MAC + b"\x08\x00" + ip + l4


def main():
    iface, n_flows, n_repeat, out = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
    gap = float(sys.argv[5]) if len(sys.argv) > 5 else 0.002
    rng = random.Random(42)
    flows = [(rng.getrandbits(32), rng.getrandbits(32), rng.randrange(1, 65536), rng.randrange(1, 65536),
              rng.choice((6, 17))) for _ in range(n_flows)]

    s = socket.socket(socket.AF_PACKET, socket.SOCK_RAW)
    s.bind((iface, 0))
    with open(out, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["seq", "src_ip", "dst_ip", "src_port", "dst_port", "proto"])
        for seq, flow in enumerate(flows + flows[:n_repeat]):
            s.send(frame(*flow, seq))
            w.writerow([seq, *flow])
            time.sleep(gap)


if __name__ == "__main__":
    main()
