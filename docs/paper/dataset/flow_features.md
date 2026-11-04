# Flow-Features aus der Literatur (SSH-Brute-Force)

Quellen: PDFs in [docs/paper/dataset/](../paper/dataset/)

| Kürzel | Paper | 
|---|---|
| **V09** | Vykopal et al., *Network-based Dictionary Attack Detection* (ICFN 2009) |
| **H12** | Hellemons et al., *SSHCure* (AIMS 2012) | NetFlow, 1-min-Fenster | Schwellwerte + Phasen-Automat (Scan → BF → Die-off) |
| **N14** | Najafabadi et al., *ML for Detecting Brute Force Attacks at the Network Level* (BIBE 2014) |
| **S17** | Sadasivam et al., *Detection of Severe SSH Attacks Using Honeypot Servers and ML* (JSN 2017) |

## Feature-Matrix

✓ = Feature, (✓) = nur Schlüssel/Filter, – = nicht genutzt

| Feature | V09 | H12 | N14 | S17 |
|---|---|---|---|---|
| 5-Tupel (IPs, Ports, Proto) | (✓) | (✓) | Ports optional, IPs ausgeschl. | (✓) |
| Flow-Start / Abstand zw. Versuchen | ✓ | (✓) | – | – |
| Flow-Dauer | ✓ ≤ 5 s | – | ✓ | – |
| Inter-Arrival-Time (Mittel, Varianz) | – | – | – | ✓ wichtigstes Feature |
| Pakete (gesamt / je Richtung) | ✓ 10–30 | ✓ | ✓ / – | ✓ / ✓ |
| Bytes (gesamt / je Richtung) | ✓ 1,4–5 kB | – | ✓ / – | ✓ / ✓ |
| Payload-Bytes (gesamt / je Richtung) | – | – | – | ✓ / ✓ |
| Packets per Flow (PPF) | – | ✓ Kernmetrik¹ | – | – |
| Bytes per Packet | ✓ | – | – | – |
| TCP-Flags (OR, initial, session) | – | – | ✓ | – |
| Anzahl ACK / PSH / RST | – | – | – | ✓ |
| Flows pro Angreifer & Zeitfenster | ✓ ab 20 Versuchen | ✓ ≥ 20/min BF, ≥ 200/min Scan | – | – |
| Abweichung letzter Flow (Login-Erfolg) | ✓ | ✓ PPF-Wechsel | – | – |

¹ Scan ≤ 2, Brute-Force 8–14, Die-off < 8 oder > 14
