# Flow-Features aus der Literatur (SSH-Brute-Force)

Quellen: PDFs in [docs/paper/dataset/](./)

| Kürzel | Paper | 
|---|---|
| **V09** | Vykopal et al., *Network-based Dictionary Attack Detection* (ICFN 2009) |
| **H12** | Hellemons et al., *SSHCure* (AIMS 2012) | NetFlow, 1-min-Fenster | Schwellwerte + Phasen-Automat (Scan → BF → Die-off) |
| **N14** | Najafabadi et al., *ML for Detecting Brute Force Attacks at the Network Level* (BIBE 2014) |
| **S17** | Sadasivam et al., *Detection of Severe SSH Attacks Using Honeypot Servers and ML* (JSN 2017) |
| **H20** | Hynek, Beneš, Čejka, Kubátová, *Refined Detection of SSH Brute-Force Attackers Using ML* (IFIP SEC 2020) – Joy-Exporter, > 70 Kandidaten → 11 Features, AdaBoost |
| **NF3** | Sarhan et al., *Towards a Standard Feature Set for NIDS Datasets* (2021, NetFlow v2, 43 Felder) + Luay et al., *Temporal Analysis of NetFlow Datasets* (2025, NetFlow v3, 53 Felder) – nProbe, enthält NF3-CSE-CIC-IDS2018 mit Klasse *SSH-Bruteforce* |
| **I26** | Wei et al., *immUNITY: Detecting and Mitigating Low Volume & Slow Attacks with Programmable Switches and SmartNICs* (arXiv 2026) – P4-Switch + SmartNIC, Entscheidungsbaum (Tiefe 8, 10 Features per RFE aus CICFlowMeter) + Zeek-Regeln flow-übergreifend |

Nicht aufgenommen: `8Ymt1gUxktJCWBOH8q1J6zeaD9At8XdwXFxxJIim.pdf` = Liu, *SSH Application Classification Based on ML* (MLTP 2021) – klassifiziert SSH-Tunnel-Anwendungen, kein Brute-Force.

## Feature-Matrix

✓ = Feature, (✓) = nur Schlüssel/Filter, – = nicht genutzt, ? = unklar (H20: Volltext nicht gelesen, nur Abstract/Sekundärquellen)

| Feature | V09 | H12 | N14 | S17 | H20 | NF3 | I26 |
|---|---|---|---|---|---|---|---|
| 5-Tupel (IPs, Ports, Proto) | (✓) | (✓) | Ports optional, IPs ausgeschl. | (✓) | ? | ✓ alle Felder enthalten | Dst-Port als Feature |
| Flow-Start / Abstand zw. Versuchen | ✓ | (✓) | – | – | ? | ✓ `FLOW_START/END_MILLISECONDS` | – |
| Flow-Dauer | ✓ ≤ 5 s | – | ✓ | – | ? | ✓ gesamt + je Richtung (`DURATION_IN/OUT`) | ✓ |
| Inter-Arrival-Time | – | – | – | ✓ Mittel, Varianz; wichtigstes Feature | ✓ Zeiten zw. Paketen² | ✓ min/max/avg/std je Richtung | ✓ min (Flow-IAT) |
| Pakete (gesamt / je Richtung) | ✓ 10–30 | ✓ | ✓ / – | ✓ / ✓ | ? | – / ✓ | – |
| Bytes (gesamt / je Richtung) | ✓ 1,4–5 kB | – | ✓ / – | ✓ / ✓ | ? | – / ✓ | – |
| Payload-Bytes (gesamt / je Richtung) | – | – | – | ✓ / ✓ | ? | – | – / ✓³ |
| Packets per Flow (PPF) | – | ✓ Kernmetrik¹ | – | – | ? | – | – |
| Bytes per Packet | ✓ | – | – | – | ? | – | – |
| Min/Max-Paketlänge | – | – | – | – | ? | ✓ min/max IP-Länge | ✓ min fwd, max gesamt³ |
| Paketlängen-Histogramm | – | – | – | – | – | ✓ 5 Buckets (≤128 … ≤1514 B) | – |
| Länge einzelner Pakete (Sequenz) | – | – | – | – | ✓ frühe Pakete, z. B. 9. Paket² | – | – |
| Raten (Bytes/s, Throughput) | – | – | – | – | ? | ✓ je Richtung | – |
| TCP-Flags (OR, initial, session) | – | – | ✓ | – | ? | ✓ OR gesamt, Client, Server | – |
| Anzahl ACK / PSH / RST | – | – | – | ✓ | ? | – | ✓ |
| TCP-Window (max) | – | – | – | – | ? | ✓ je Richtung | – |
| Retransmissions (Bytes, Pakete) | – | – | – | – | ? | ✓ je Richtung | – |
| TTL (min/max) | – | – | – | – | ? | ✓ | – |
| Flows pro Angreifer & Zeitfenster | ✓ ab 20 Versuchen | ✓ ≥ 20/min BF, ≥ 200/min Scan | – | – | ? | – | ✓ Zeek-Schwellwerte auf SmartNIC⁴ |
| Abweichung letzter Flow (Login-Erfolg) | ✓ | ✓ PPF-Wechsel | – | – | ✓ erfolgreicher vs. fehlgeschl. Login per ML² | – | – |

¹ Scan ≤ 2, Brute-Force 8–14, Die-off < 8 oder > 14
² Laut Abstract/Snippets; die genaue Liste der 11 Features steht nur im Volltext (Springer, Paywall).
³ CICFlowMeter berechnet Paketlängen aus der Payload; I26 nutzt Summe fwd/bwd, min fwd, max.
⁴ Regelbasiert, nicht im ML-Vektor; Klassifikation per ML ab dem 3. Paket eines Flows, kürzere Flows nur über Regeln.
