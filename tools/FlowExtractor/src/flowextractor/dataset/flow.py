import os
import ipaddress
import colored
from scapy.layers.inet import IP, TCP, UDP
import pandas as pd
from flowextractor.dataset import sshd_log
import time
from flowextractor.dataset import gobuster
from flowextractor.dataset import slowloris

# Must match NUM_PCKGS_BEFORE_CLASSIFICATION in huginn/common.h: the DPA classifies a flow after this many packets and
# then frees its entry, so the next packet of the same connection starts a fresh window.
PACKETS_PER_WINDOW = 8

def canonical_five_tuple(packet):
    """Bidirectional flow key like parse_five_tuple() in huginn/device/kernel.c: both directions of a connection map to
    the same tuple, ordered so that the numerically lower IP (on equal IPs the lower port) comes first."""
    if not packet.haslayer(IP) or (not packet.haslayer(TCP) and not packet.haslayer(UDP)):
        return None

    ip_layer = packet[IP]
    layer_4 = packet[TCP] if packet.haslayer(TCP) else packet[UDP]

    src_ip, dst_ip = ip_layer.src, ip_layer.dst
    src_port, dst_port = layer_4.sport, layer_4.dport
    src_key, dst_key = int(ipaddress.IPv4Address(src_ip)), int(ipaddress.IPv4Address(dst_ip))

    if src_key > dst_key or (src_key == dst_key and src_port > dst_port):
        src_ip, dst_ip = dst_ip, src_ip
        src_port, dst_port = dst_port, src_port

    return src_ip, dst_ip, src_port, dst_port, ip_layer.proto

def calculate_packet_hash(packet):
    five_tuple = canonical_five_tuple(packet)
    if five_tuple is None:
        return None
    return hash(five_tuple)

class FlowTableManager:
    def __init__(self):
        self.flow_table = {}

    def add_packet(self, packet):
        five_tuple = canonical_five_tuple(packet)
        if five_tuple is None:
            return
        flow_hash = hash(five_tuple)

        if flow_hash not in self.flow_table:
            src_ip, dst_ip, src_port, dst_port, _ = five_tuple
            self.flow_table[flow_hash] = Flow(flow_hash, src_ip, dst_ip, src_port, dst_port)

        self.flow_table[flow_hash].add_packet(packet)

    def add_packets(self, packets):
        for packet in packets:
            self.add_packet(packet)

    def get_number_of_flows(self):
        return len(self.flow_table)

    def label_ssh_flows(self):
        sshd_log.label_ssh_flows(self.flow_table.values())

    def label_slowloris_flows(self, attacker_ip):
        slowloris.label_slowloris_flows(self.flow_table.values(), attacker_ip)

    def label_gobuster_flows(self, attacker_ip):
        gobuster.label_gobuster_flows(self.flow_table.values(), attacker_ip)

    def print_flow_table(self):
        nr_single_packet_flows = 0
        for flow_hash, flow in self.flow_table.items():
            if flow.total_packets > 1:
                print(f"=============\nFlow Hash: {flow_hash:x}"
                    f"\n\tNumber of Packets: {flow.total_packets} ({len(flow.windows)} complete windows of {PACKETS_PER_WINDOW}, statistics below: current window)"
                    f"\n\tSource IP: {flow.src_ip}"
                    f"\n\tDestination IP: {flow.dst_ip}"
                    f"\n\tSource Port: {flow.src_port}"
                    f"\n\tDestination Port: {flow.dst_port}"
                    f"\n\tAverage Packet Size: {flow.avg_packet_size:.2f} bytes"
                    f"\n\tMinimum Packet Size: {flow.min_packet_size} bytes"
                    f"\n\tMaximum Packet Size: {flow.max_packet_size} bytes"
                    f"\n\tTotal Bytes: {flow.total_bytes} bytes"
                    f"\n\tInter-Arrival Time (IAT) Min: {flow.iat_min:.6f} seconds"
                    f"\n\tInter-Arrival Time (IAT) Max: {flow.iat_max:.6f} seconds"
                    f"\n\tInter-Arrival Time (IAT) Mean: {flow.iat_mean:.6f} seconds")
            else:
                nr_single_packet_flows += 1
        print(f"Number of single-packet flows: {nr_single_packet_flows}")

    def print_flow_table_summary(self):
        total_flows = len(self.flow_table)
        single_packet_flows = sum(1 for flow in self.flow_table.values() if flow.total_packets == 1)
        multi_packet_flows = total_flows - single_packet_flows
        ssh_flows = [flow for flow in self.flow_table.values() if (flow.dst_port == 22 or flow.src_port == 22)]
        print(f"Total number of flows: {total_flows}")
        print(f"Number of single-packet flows: {single_packet_flows}")
        print(f"Number of multi-packet flows: {multi_packet_flows}")
        print(f"Number of SSH flows: {len(ssh_flows)}")
        for flow in ssh_flows:
            print(f"\tSSH Flow Hash: {flow.flow_hash:x} - Source IP: {flow.src_ip}, Destination IP: {flow.dst_ip}, Source Port: {flow.src_port}, Destination Port: {flow.dst_port}, Label: {flow.label}")

    def write_flow_vectors_to_csv(self, file_path):
        flow_vectors = []
        delete = []
        # flows are written once idle so that labels which depend on later evidence (sshd log) are final
        for flow_hash, flow in self.flow_table.items():
            if time.time() - flow.last_seen_time > 60:
                for feature_vector in flow.windows:
                    flow_vectors.append([flow_hash] + feature_vector + [flow.label, flow.attack_type])
                delete.append(flow_hash)

        number_of_flows_written = len(flow_vectors)

        for flow_hash in delete:
            del self.flow_table[flow_hash]

        df = pd.DataFrame(flow_vectors, columns=[
            "Flow Hash",
            "Source IP",
            "Destination IP",
            "Number of Packets",
            "Source Port",
            "Destination Port",
            "Average Packet Size",
            "Minimum Packet Size",
            "Maximum Packet Size",
            "Total Bytes",
            "IAT Min",
            "IAT Max",
            "IAT Mean",
            "Label",
            "Attack Type"
        ])
        df.to_csv(file_path, index=False, mode='a', header=not os.path.exists(file_path))
        if number_of_flows_written > 0:
            print(colored.fg("green") + f"{number_of_flows_written} flow vectors written to {file_path}" + colored.attr("reset"))

    def clear_flow_table(self):
        self.flow_table = {}

class Flow:
    """Statistics are kept per window of PACKETS_PER_WINDOW packets, like the flow entries on the DPA: every complete
    window becomes one feature vector, an incomplete last window is never classified on the device and is dropped."""

    def __init__(self, flow_hash=None, src_ip=None, dst_ip=None, src_port=None, dst_port=None):
        self.src_ip = src_ip
        self.dst_ip = dst_ip
        self.src_port = src_port
        self.dst_port = dst_port
        self.flow_hash = flow_hash
        self.total_packets = 0
        self.windows = []
        self.last_seen_time = time.time()
        self.first_packet_time = None
        self.label = "benign"
        self.attack_type = "n/a"
        self._reset_window()

    def _reset_window(self):
        self.number_of_packets = 0
        self.avg_packet_size = 0
        self.min_packet_size = float('inf')
        self.max_packet_size = 0
        self.total_bytes = 0
        self.iat_min = float('inf')
        self.iat_max = 0
        self.iat_mean = 0
        # no IAT across window borders: on the DPA the next window is a fresh flow entry
        self.last_packet_time = None

    def add_packet(self, packet):
        self.total_packets += 1
        self.number_of_packets += 1

        if self.first_packet_time is None:
            self.first_packet_time = packet.time
        self.last_seen_time = packet.time

        packet_size = len(packet)
        self.total_bytes += packet_size
        self.avg_packet_size = self.total_bytes / self.number_of_packets
        self.min_packet_size = min(self.min_packet_size, packet_size)
        self.max_packet_size = max(self.max_packet_size, packet_size)

        if self.last_packet_time is not None:
            iat = packet.time - self.last_packet_time
            self.iat_min = min(self.iat_min, iat)
            self.iat_max = max(self.iat_max, iat)
            number_of_iats = self.number_of_packets - 1
            self.iat_mean = ((self.iat_mean * (number_of_iats - 1)) + iat) / number_of_iats
        self.last_packet_time = packet.time

        if self.number_of_packets == PACKETS_PER_WINDOW:
            self.windows.append(self.build_feature_vector())
            self._reset_window()

    def build_feature_vector(self):
        out_vector = [
            self.src_ip,
            self.dst_ip,
            self.number_of_packets,
            self.src_port,
            self.dst_port,
            self.avg_packet_size,
            self.min_packet_size,
            self.max_packet_size,
            self.total_bytes,
            self.iat_min,
            self.iat_max,
            self.iat_mean
        ]
        return out_vector
