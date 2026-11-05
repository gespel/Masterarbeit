# Flow-Features aus der Literatur (SSH-Brute-Force)

Quellen: PDFs in [docs/paper/dataset/](./)

| Kürzel | Paper | 
|---|---|
| **V09** | Vykopal et al., *Network-based Dictionary Attack Detection* (ICFN 2009) |
| **H12** | Hellemons et al., *SSHCure* (AIMS 2012) | NetFlow, 1-min-Fenster | Schwellwerte + Phasen-Automat (Scan → BF → Die-off) |
| **N14** | Najafabadi et al., *ML for Detecting Brute Force Attacks at the Network Level* (BIBE 2014) |
| **S17** | Sadasivam et al., *Detection of Severe SSH Attacks Using Honeypot Servers and ML* (JSN 2017) |
| **H20** | Hynek, Beneš, Čejka, Kubátová, *Refined Detection of SSH Brute-Force Attackers Using ML* (IFIP SEC 2020) – Joy-Biflows, > 70 Kandidaten → 11 Features (Information Gain Ratio), AdaBoost-Baum (10 Iter., Tiefe 10), 99,47 % Accuracy; Datensatz: [CESNET/traffic-datasets/ssh](https://github.com/CESNET/traffic-datasets/tree/master/ssh/) |
| **NF3** | Sarhan et al., *Towards a Standard Feature Set for NIDS Datasets* (2021, NetFlow v2, 43 Felder) + Luay et al., *Temporal Analysis of NetFlow Datasets* (2025, NetFlow v3, 53 Felder) – nProbe, enthält NF3-CSE-CIC-IDS2018 mit Klasse *SSH-Bruteforce* |
| **I26** | Wei et al., *immUNITY: Detecting and Mitigating Low Volume & Slow Attacks with Programmable Switches and SmartNICs* (arXiv 2026) – P4-Switch + SmartNIC, Entscheidungsbaum (Tiefe 8, 10 Features per RFE aus CICFlowMeter) + Zeek-Regeln flow-übergreifend |

Nicht aufgenommen: `8Ymt1gUxktJCWBOH8q1J6zeaD9At8XdwXFxxJIim.pdf` = Liu, *SSH Application Classification Based on ML* (MLTP 2021) – klassifiziert SSH-Tunnel-Anwendungen, kein Brute-Force.

## Feature-Matrix

✓ = Feature, (✓) = nur Schlüssel/Filter, – = nicht genutzt. Bei H20 in Klammern: Feldname und Information Gain Ratio aus Table 1

| Feature | V09 | H12 | N14 | S17 | H20 | NF3 | I26 |
|---|---|---|---|---|---|---|---|
| 5-Tupel (IPs, Ports, Proto) | (✓) | (✓) | Ports optional, IPs ausgeschl. | (✓) | (✓) Src/Dst-IP nur in Knowledge Base | ✓ alle Felder enthalten | Dst-Port als Feature |
| Flow-Start / Abstand zw. Versuchen | ✓ | (✓) | – | – | (✓) Timestamp in Knowledge Base | ✓ `FLOW_START/END_MILLISECONDS` | – |
| Flow-Dauer | ✓ ≤ 5 s | – | ✓ | – | ✓ (`duration` 0,836) | ✓ gesamt + je Richtung (`DURATION_IN/OUT`) | ✓ |
| Inter-Arrival-Time | – | – | – | ✓ Mittel, Varianz; wichtigstes Feature | ✓ Mittel, Median (`avgIpt` 0,888, `medIpt` 0,942 = höchster IGR) | ✓ min/max/avg/std je Richtung | ✓ min (Flow-IAT) |
| Pakete (gesamt / je Richtung) | ✓ 10–30 | ✓ | ✓ / – | ✓ / ✓ | – / ✓ (`numPktsIn` 0,666, `numPktsOut` 0,754) | – / ✓ | – |
| Bytes (gesamt / je Richtung) | ✓ 1,4–5 kB | – | ✓ / – | ✓ / ✓ | – / ✓ (`bytesIn` 0,758, `bytesOut` 0,756) | – / ✓ | – |
| Payload-Bytes (gesamt / je Richtung) | – | – | – | ✓ / ✓ | – | – | – / ✓³ |
| Packets per Flow (PPF) | – | ✓ Kernmetrik¹ | – | – | – | – | – |
| Bytes per Packet | ✓ | – | – | – | – | – | – |
| Min/Max-Paketlänge | – | – | – | – | – | ✓ min/max IP-Länge | ✓ min fwd, max gesamt³ |
| Paketlängen-Histogramm | – | – | – | – | – | ✓ 5 Buckets (≤128 … ≤1514 B) | – |
| Länge einzelner Pakete (Sequenz) | – | – | – | – | ✓ Pakete 9–12 (`dp9bytes`–`dp12bytes`, 0,754–0,868)² | – | – |
| Raten (Bytes/s, Throughput) | – | – | – | – | – | ✓ je Richtung | – |
| TCP-Flags (OR, initial, session) | – | – | ✓ | – | – | ✓ OR gesamt, Client, Server | – |
| Anzahl ACK / PSH / RST | – | – | – | ✓ | – | – | ✓ |
| TCP-Window (max) | – | – | – | – | – | ✓ je Richtung | – |
| Retransmissions (Bytes, Pakete) | – | – | – | – | – | ✓ je Richtung | – |
| TTL (min/max) | – | – | – | – | – | ✓ | – |
| Flows pro Angreifer & Zeitfenster | ✓ ab 20 Versuchen | ✓ ≥ 20/min BF, ≥ 200/min Scan | – | – | ✓ ≥ 3 Fehl-Logins pro Src-IP⁵ | – | ✓ Zeek-Schwellwerte auf SmartNIC⁴ |
| Abweichung letzter Flow (Login-Erfolg) | ✓ | ✓ PPF-Wechsel | – | – | ✓ Kernidee: ML klassifiziert jeden Flow als erfolgreicher / fehlgeschl. Login | – | – |

¹ Scan ≤ 2, Brute-Force 8–14, Die-off < 8 oder > 14
² Gezählt werden nur SSH-Pakete beider Richtungen (TCP-Kontrollpakete und Retransmissions filtert der Exporter). Ab dem 9. Paket beginnt die Authentifizierung; die Pakete 9–12 tragen die Server-Antworten auf Login-Versuche, bei Fehlversuchen meist gleich groß. Client-Features (SSH-Version, Client-Name, Cipher-Suites) wurden verworfen (IGR < 0,3), weil Angreifer dieselben Clients nutzen (OpenSSH, PuTTY, libssh).
⁵ Alarm, sobald eine Quell-IP ≥ 3 aufeinanderfolgende Fehl-Logins hat (Fail2Ban-Default); Knowledge Base hält ≥ 24 h, über alle Ziele hinweg (gegen „low and slow“-Botnetze).
³ CICFlowMeter berechnet Paketlängen aus der Payload; I26 nutzt Summe fwd/bwd, min fwd, max.
⁴ Regelbasiert, nicht im ML-Vektor; Klassifikation per ML ab dem 3. Paket eines Flows, kürzere Flows nur über Regeln.
