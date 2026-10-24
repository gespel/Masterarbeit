# Abkürzungen

## Hardware und Funktionen

| Abkürzung | Ausgeschrieben | Bedeutung |
|---|---|---|
| BF3 | BlueField-3 | NVIDIA-DPU: ConnectX-7-NIC plus Arm-Kerne plus DPA auf einem Chip |
| DPU | Data Processing Unit | Netzwerkkarte mit eigenen programmierbaren Prozessoren |
| NIC | Network Interface Card | Netzwerkkarte |
| DPA | Data Path Accelerator | RISC-V-Prozessor der BF3 für Paketverarbeitung im Datenpfad |
| EU | Execution Unit | Hardware-Thread der DPA (16 pro Kern, auf unserer Karte 190 sichtbar) |
| PCIe | Peripheral Component Interconnect Express | Bus zwischen Host und Karte |
| PF | Physical Function | „Echte“ PCIe-Funktion der Karte, z. B. die des x86-Hosts |
| VF | Virtual Function | Per SR-IOV abgeleitete, virtuelle PCIe-Funktion einer PF |
| SR-IOV | Single Root I/O Virtualization | PCIe-Standard, mit dem eine PF mehrere VFs bereitstellt |
| SF | Sub Function | Leichtgewichtige Funktion ohne eigene PCIe-Adresse, mit eigener vport (bei uns `mlx5_2`) |
| ECPF | Embedded CPU Physical Function | Die PF der Arm-Seite; eSwitch-Manager und Besitzer der DPA-EUs (bei uns `mlx5_0`) |
| vHCA | virtual Host Channel Adapter | Eine logische NIC-Funktion (PF, VF, SF, ECPF) mit eigener ID und eigenem Objekt-Namensraum |
| HCA | Host Channel Adapter | InfiniBand-Begriff für die Netzwerkkarte |
| GVMI | Guest Virtual Machine Identifier | Hardware-ID einer Funktion, praktisch gleichbedeutend mit vhca_id |
| MMIO | Memory-Mapped I/O | Zugriff auf Geräteregister über normale Speicheradressen |
| DMA | Direct Memory Access | NIC schreibt/liest Speicher ohne CPU-Beteiligung |
| DDR | Double Data Rate (SDRAM) | Hauptspeicher der DPU |

## Switching und Steering

| Abkürzung | Ausgeschrieben | Bedeutung |
|---|---|---|
| eSwitch | Embedded Switch | Hardware-Switch in der NIC, verteilt Pakete zwischen den vports |
| vport | virtual port | Anschluss einer Funktion am eSwitch; Uplink = `0xFFFF`, ECPF = `0xFFFE` |
| Uplink | – | Physischer Netzwerkport zum Kabel (Representor `p0`) |
| FDB | Forwarding Database | Steering-Tabelle des eSwitch (Stufe 1): an welche Funktion geht ein Paket |
| NIC_RX | NIC Receive | Steering-Domain einer Funktion (Stufe 2): in welche Empfangsqueue |
| NIC_TX | NIC Transmit | Steering-Domain einer Funktion für ausgehende Pakete |
| DR / SWS | Direct Rules / Software Steering | mlx5dv-API, mit der Programme Steering-Regeln direkt in Hardware schreiben |
| HWS | Hardware Steering | Neuere Steering-Variante, u. a. von DOCA Flow und DPDK genutzt |
| switchdev | – | eSwitch-Modus, in dem die Arm-Seite den Switch verwaltet und Representors erhält |
| Representor | – | Netdev auf der Arm-Seite, das eine vport vertritt (`p0`, `pf0hpf`, `en3f0pf0sf0`); Griff für den Slow-Path |
| OVS | Open vSwitch | Software-Switch auf der Arm-Seite, lernt Flows und lagert sie in die FDB aus |
| tc / tc-flower | Traffic Control | Linux-Subsystem, über das OVS Regeln in die Hardware offloaded |
| Offload | – | Regel/Arbeit wird von Software in Hardware verlagert |
| Slow-Path | – | Weg eines Pakets ohne passende FDB-Regel: über den Representor an Software (OVS) |
| Upcall | – | OVS-Begriff: Datapath reicht ein Paket ohne Flow an den Userspace zur Entscheidung |
| Mirror | – | FDB-Regel mit zwei Zielen: Original weiter, Kopie an eine zweite vport |
| RSS | Receive Side Scaling | Verteilung von Paketen per Hash (z. B. über das 5-Tupel) auf mehrere Queues |
| MAC | Media Access Control (Adresse) | Ethernet-Adresse; Funktionen filtern standardmäßig auf die eigene MAC |
| LLDP | Link Layer Discovery Protocol | Nachbarerkennung auf Layer 2 (EtherType `0x88cc`) |
| ARP | Address Resolution Protocol | Auflösung IPv4 → MAC |

## Queues und Speicher (mlx5 / FlexIO)

| Abkürzung | Ausgeschrieben | Bedeutung |
|---|---|---|
| RQ | Receive Queue | Ring mit leeren Puffern, in die die NIC empfangene Pakete schreibt |
| SQ | Send Queue | Ring mit Sendeaufträgen |
| CQ | Completion Queue | Ring, in dem die NIC fertige Empfangs-/Sendeoperationen meldet |
| CQE | Completion Queue Entry | Ein Eintrag in der CQ (64 B), enthält u. a. Länge und WQE-Index |
| WQ / WQE | Work Queue / Work Queue Element | Allgemeiner Begriff für RQ/SQ bzw. einen Eintrag darin |
| MPRQ | Multi-Packet Receive Queue (Striding RQ) | RQ, bei der mehrere Pakete einen großen Puffer teilen |
| EQ / EQE | Event Queue / Event Queue Entry | Queue für Events, z. B. „neue CQE auf armierter CQ“ |
| TIR | Transport Interface Receive | Empfangseingang, auf den Steering-Regeln zeigen; verteilt auf eine oder mehrere RQs |
| TIS | Transport Interface Send | Sendegegenstück zur TIR |
| RQT | Receive Queue Table | Indirektionstabelle einer RSS-TIR (Hash → RQ) |
| DBR | Doorbell Record | Speicherstelle, in der Producer-/Consumer-Index einer Queue steht |
| PI / CI | Producer Index / Consumer Index | Zähler: wie weit wurde geschrieben bzw. verarbeitet |
| UAR | User Access Region | MMIO-Seite für Doorbells; per `flexio_uar_extend` auf eine andere Funktion erweiterbar |
| Outbox | – | Doorbell-Schnittstelle eines DPA-Threads; zeigt auf eine Funktion (umschaltbar per `flexio_dev_outbox_config_uar_extension`) |
| Arm (CQ) | – | CQ so markieren, dass die nächste CQE ein Event auslöst (nicht zu verwechseln mit der Arm-CPU) |
| PD | Protection Domain | Schutzbereich, dem Queues und Speicherschlüssel einer Funktion angehören |
| MKey | Memory Key | Schlüssel, der der NIC Zugriff auf einen Speicherbereich erlaubt |
| UMEM | User Memory | Bei der NIC registrierter Speicherbereich |
| RPC | Remote Procedure Call | Aufruf einer DPA-Funktion vom Host-Programm aus (`flexio_process_call`) |

## Software und Werkzeuge

| Abkürzung | Ausgeschrieben | Bedeutung |
|---|---|---|
| DOCA | Data Center Infrastructure-on-a-Chip Architecture | NVIDIA-SDK für BlueField (enthält FlexIO, DOCA Flow, dpacc, …) |
| FlexIO | – | Low-Level-SDK zum Programmieren der DPA (Host-Lib `libflexio`, Device-Lib `libflexio-dev`) |
| dpacc | DPA Compiler Collection | Compiler-Treiber für DPA-Programme |
| dpaeumgmt | DPA EU Management | Werkzeug zum Partitionieren der DPA-EUs auf Funktionen |
| DPDK | Data Plane Development Kit | Userspace-Paketverarbeitung mit Polling-Treibern (z. B. `velox-rest`) |
| EAL | Environment Abstraction Layer | Initialisierungsschicht von DPDK (Argumente wie `-l 0-5`) |
| rte_flow | – | DPDK-API für Steering-Regeln in Hardware |
| Verbs / ibv | InfiniBand Verbs | Low-Level-API (`libibverbs`) zum Öffnen von Geräten (`mlx5_0`, …) und Anlegen von Ressourcen |
| mlx5dv | mlx5 Direct Verbs | NVIDIA-spezifische Erweiterungen der Verbs (u. a. DR-Steering) |
| DevX | – | Schnittstelle zum direkten Absetzen von Firmware-Befehlen (PRM) |
| PRM | Programmer's Reference Manual | Firmware-Befehlssatz der ConnectX-Familie |

## Sicherheit und Netzwerk

| Abkürzung | Ausgeschrieben | Bedeutung |
|---|---|---|
| IDS | Intrusion Detection System | Erkennt Angriffe (passiv, z. B. auf gespiegeltem Verkehr) |
| IPS | Intrusion Prevention System | Erkennt und blockiert (inline, Pakete laufen durch das System) |
| DPI | Deep Packet Inspection | Untersuchung der Nutzdaten, nicht nur der Header |
| 5-Tupel | – | Quell-IP, Ziel-IP, Quell-Port, Ziel-Port, Protokoll; identifiziert einen Flow |
| Mpps | Million packets per second | Paketrate |
| IPC | Instructions per Cycle | Instruktionen pro Takt |
