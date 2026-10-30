import argparse
import multiprocessing
import random
import socket
import struct
import time
import tqdm

from scapy.all import IP, TCP, Ether, Raw

SF_MAC = "02:92:d9:85:7f:f8"   # MAC of enp3s0f0s0 (the SF netdev)
SRC_MAC = "02:00:00:00:00:01"
TCP_PORTS = 14 + 20        # Ethernet + IPv4 header without options
TCP_CSUM = TCP_PORTS + 16


def main():
	ap = argparse.ArgumentParser()
	ap.add_argument("--iface", default="en3f0pf0sf0")
	ap.add_argument("--dst-mac", default=SF_MAC)
	ap.add_argument("--src-ip", default="10.0.0.1")
	ap.add_argument("--dst-ip", default="10.0.0.2")
	ap.add_argument("--seed", type=int, default=None, help="seed for the random ports, default: new ports every run")
	ap.add_argument("--flows", type=int, default=4)
	ap.add_argument("--count", type=int, default=10, help="packets per flow")
	ap.add_argument("--flags", default="S")
	ap.add_argument("--payload", type=int, default=8, help="payload bytes")
	ap.add_argument("--gap", type=float, default=0, help="seconds between rounds (one packet per flow), 0 = as fast as possible")
	ap.add_argument("--procs", type=int, default=4, help="sending processes, each sends every procs-th flow")
	a = ap.parse_args()

	rng = random.Random(a.seed)
	ports = [(rng.randrange(1, 65536), rng.randrange(1, 65536)) for _ in tqdm.tqdm(range(a.flows), desc="generating flows")]
	# scapy builds one template with ports 0/0, per flow only the ports and the TCP checksum are patched in
	tmpl = bytes(Ether(src=SRC_MAC, dst=a.dst_mac)
	             / IP(src=a.src_ip, dst=a.dst_ip)
	             / TCP(sport=0, dport=0, flags=a.flags)
	             / Raw(b"x" * a.payload))
	inv_csum0 = ~struct.unpack_from("!H", tmpl, TCP_CSUM)[0] & 0xFFFF
	frames = []
	for sport, dport in tqdm.tqdm(ports, desc="building frames"):
		s = inv_csum0 + sport + dport   # RFC 1624 incremental update, old ports were 0
		s = (s & 0xFFFF) + (s >> 16)
		s = (s & 0xFFFF) + (s >> 16)
		f = bytearray(tmpl)
		struct.pack_into("!HH", f, TCP_PORTS, sport, dport)
		struct.pack_into("!H", f, TCP_CSUM, ~s & 0xFFFF)
		frames.append(bytes(f))
	for sport, dport in ports[:10]:
		print(f"  {a.src_ip}:{sport} -> {a.dst_ip}:{dport}")
	if a.flows > 10:
		print(f"  ... ({a.flows - 10} more)")

	# every process sends every procs-th flow on its own socket, frames are inherited through fork
	mp = multiprocessing.get_context("fork")
	sent = mp.Array("Q", a.procs)
	procs = [mp.Process(target=send_part, args=(a, frames[i::a.procs], sent, i)) for i in range(a.procs)]
	t0 = time.perf_counter()
	for p in procs:
		p.start()
	try:
		for p in procs:
			p.join()
	except KeyboardInterrupt:
		for p in procs:
			p.join()
	dt = time.perf_counter() - t0
	total = sum(sent)
	print(f"sent {total} TCP packets ({a.flows} flows x {a.count}) on {a.iface} with {a.procs} processes in {dt:.1f} s ({total / dt / 1e3:.0f} kpps)")


def send_part(a, frames, sent, i):
	s = socket.socket(socket.AF_PACKET, socket.SOCK_RAW)
	s.bind((a.iface, 0))
	send = s.send
	try:
		for n in range(a.count):
			for f in frames:
				send(f)
			sent[i] += len(frames)
			if a.gap:
				time.sleep(a.gap)
	except KeyboardInterrupt:
		pass


if __name__ == "__main__":
	main()
