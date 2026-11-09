# Wie Huginn Pakete auf die EUs verteilt

Dieses Tutorial folgt einem Paket vom Kabel bis zu einer EU und erklärt danach, was der Host dafür anlegen muss. Grundlage ist der Code in [`huginn/host.c`](../huginn/host.c), [`huginn/device/kernel.c`](../huginn/device/kernel.c) und [`huginn/common.h`](../huginn/common.h), Stand 09.11.2026.

„Host“ meint hier immer die Arm-Kerne der BlueField, auf denen `host.c` läuft. Der Host baut alles auf, die Pakete selbst fasst er nie an. Grundbegriffe wie RQ, CQ und TIR stehen in [rq_cq.md](rq_cq.md), [paket_ablauf.md](paket_ablauf.md) und [abkuerzungen.md](abkuerzungen.md).

## Überblick

```
Kabel → p0 → OVS-Mirror → SF mlx5_2
                             │
                     NIC_RX-Steering
                    ┌────────┴────────┐
              ip_protocol = 6       alles andere
                    │                 │
              RSS-TIR (Hash)     TIR von RQ 0
                    │                 │
              RQT (2048 Einträge)     │
                    │                 │
              RQ von EU k           RQ von EU 0
                    └────────┬────────┘
                             │
     Paket per DMA in RX-Puffer → CQE in CQ → Event → pkt_handler auf der EU
```

Die Verteilung passiert vollständig in der NIC. Wenn `pkt_handler` läuft, ist längst entschieden, welche EU das Paket bearbeitet.

## Teil 1: Der Weg eines Pakets

### Schritt 1: Das Paket erreicht die Subfunction

Huginn öffnet das Gerät `mlx5_2`, eine Subfunction (SF), der alle EUs zugeteilt sind. Von außen kommen Pakete nur über einen OVS-Mirror von `p0` auf diese SF. Mirror und EU-Partition gehen beim Neustart verloren und werden mit [`tools/setup_dpa.sh`](../tools/setup_dpa.sh) wiederhergestellt.

### Schritt 2: Steering-Regeln teilen den Verkehr auf

Die Funktion `steer_flows` legt in der NIC_RX-Domain der SF eine Tabelle mit zwei Regeln an. Das Grundprinzip hat zwei Stufen:

- Ein **Matcher** legt fest, *welche Bits* verglichen werden (Maske) und mit welcher Priorität.
- Eine **Regel** in diesem Matcher legt fest, *welchen Wert* diese Bits haben müssen und wohin das Paket geht.

Beide nutzen denselben 64 Byte großen Puffer `match`, dessen Aufbau das Layout `fte_match_set_lyr_2_4` der Hardware vorgibt. Das Feld `ip_protocol` liegt dort bei Offset `0x10`.

```c
struct mlx5dv_dr_matcher *rest = mlx5dv_dr_matcher_create(tbl, 1, 0, match); /* match all, lower priority */
DOCA_TRY(!mlx5dv_dr_rule_create(rest, match, 1, &to_eu0));

m[MATCH_IP_PROTOCOL] = 0xff;                                                 /* Maske: das ganze Byte vergleichen */
struct mlx5dv_dr_matcher *tcp = mlx5dv_dr_matcher_create(tbl, 0, 1, match); /* 1 = outer headers */

m[MATCH_IP_PROTOCOL] = IPPROTO_TCP;                                          /* Wert: 6 */
DOCA_TRY(!mlx5dv_dr_rule_create(tcp, match, 1, &to_rss));
```

Der zweite Parameter von `mlx5dv_dr_matcher_create` ist die Priorität, kleinere Werte werden zuerst geprüft. Damit gilt:

| Priorität | Matcher | Bedingung | Ziel |
|---|---|---|---|
| 0 | `tcp` | `ip_protocol == 6` | `to_rss`: wird auf alle EUs verteilt |
| 1 | `rest` | keine, passt immer | `to_eu0`: alles geht an EU 0 |

Das Ziel einer Regel ist immer ein TIR, verpackt in eine Action (`mlx5dv_dr_action_create_dest_devx_tir`). `to_eu0` nutzt den TIR, den FlexIO zu jeder RQ mitliefert (`flexio_rq_get_tir(rq[0])`). Er zeigt genau auf diese eine RQ. `to_rss` nutzt einen selbst gebauten TIR, um den es jetzt geht.

### Schritt 3: Der RSS-TIR berechnet einen Hash

Ein TIR kann auf eine einzelne RQ zeigen oder, wie hier, „indirekt“ auf eine Tabelle von RQs. Dann berechnet die NIC pro Paket einen Hash und wählt damit den Tabelleneintrag. Das nennt sich Receive Side Scaling (RSS).

FlexIO bietet dafür keine Funktion an, deshalb erzeugt `create_rss_tir` die Objekte direkt mit DevX-Kommandos an die Firmware. Ein Kommando ist ein Puffer aus Big-Endian-Wörtern mit dem Opcode am Anfang. Die Offsets stehen als Konstanten am Anfang von `host.c`.

Die Konfiguration des TIR:

| Konstante | Wert | Bedeutung |
|---|---|---|
| `TIR_DISP_INDIRECT` | `1 << 28` | Pakete über eine Tabelle verteilen |
| `TIR_SYMMETRIC` | `1 << 31` | Hin- und Rückrichtung ergeben denselben Hash |
| `rqt` | RQT-Nummer | die zu nutzende Tabelle |
| `TIR_FN_TOEPLITZ` | `2 << 28` | Hash-Funktion Toeplitz |
| `td` | TD-Nummer | Transport Domain, Pflichtangabe für jeden TIR |
| `key` | 40 Byte | Schlüssel der Toeplitz-Funktion |
| `TIR_HASH_4_TUPLE` | `0xf` | Hash über Quell-IP, Ziel-IP, Quell- und Zielport von IPv4/TCP |

### Schritt 4: Die RQT übersetzt den Hash in eine RQ

Die RQ Table (RQT) ist eine Liste von RQ-Nummern. Sie wird so gefüllt, dass die EUs reihum vorkommen:

```c
for (uint32_t i = 0; i < RQT_SIZE; i++)
	rqt_in[RQT_RQ_LIST / 4 + i] = htobe32(rqn[i % NUM_EUS]);
```

Bei 2048 Einträgen und 160 EUs bekommen die EUs 0 bis 127 je 13 Einträge und die EUs 128 bis 159 je 12. Mehr als 2048 Einträge erlaubt die Hardware nicht (`log_max_rqt_size` = 11).

### Schritt 5: Von der RQ zur EU

Warum landet ein Paket aus der RQ von EU *k* auch wirklich auf EU *k*? Das ergibt sich aus einer Kette, die `create_handler` für jede EU aufbaut:

```
RQ  ──gehört zu──→  CQ  ──weckt──→  Event-Handler-Thread  ──fest gebunden an──→  EU k
```

Die Bindung an die EU steht im Attribut des Event Handlers:

```c
.affinity = { .type = FLEXIO_AFFINITY_STRICT, .id = eu },
```

Die NIC schreibt das Paket per DMA in den nächsten RX-Puffer dieser RQ und danach einen CQE in die CQ. Der neue CQE weckt den Thread, also läuft `pkt_handler` auf EU *k*. Dort führt der Index im CQE zum Puffer:

```c
uint32_t idx = flexio_dev_cqe_get_wqe_counter(cqe) & Q_MASK;
parse_five_tuple((uint8_t *)(c->rx_bufs + idx * BUF_BSIZE), flexio_dev_cqe_get_byte_cnt(cqe), &t);
```

### Beispiel

Ein Paket `16.197.48.174:16102 → 48.250.54.224:80` wird so verteilt:

1. `ip_protocol` ist 6, der Matcher `tcp` greift, Ziel ist der RSS-TIR.
2. Die NIC berechnet den symmetrischen Hash über beide IPs und beide Ports.
3. Angenommen, der Hash wählt RQT-Eintrag 1000. Dort steht `rqn[1000 % 160]`, also die RQ von EU 40.
4. `pkt_handler` läuft auf EU 40.
5. Das Antwortpaket `48.250.54.224:80 → 16.197.48.174:16102` ergibt denselben Hash und landet ebenfalls auf EU 40.

Ein UDP-Paket derselben Hosts passt nicht auf den Matcher `tcp` und geht an EU 0.

### Warum die Verteilung symmetrisch sein muss

Huginn erfasst Flows bidirektional: `parse_five_tuple` sortiert die Endpunkte, sodass beide Richtungen denselben Eintrag in der Flow-Tabelle treffen. Damit das funktioniert, müssen beide Richtungen auf derselben EU laufen, aus zwei Gründen:

- `__dpa_thread_cycles()` zählt pro EU. Zeitstempel verschiedener EUs sind nicht vergleichbar, die Inter-Arrival-Time (IAT) wäre sonst falsch.
- Ein Flow hat so nur einen Schreiber, seine Zähler brauchen keine atomaren Zugriffe. Das gilt, solange kein anderer Flow per Hash-Kollision denselben Eintrag der gemeinsamen Tabelle trifft.

Gemessen mit 64 eingespeisten Paaren aus Hin- und Rückrichtung bei laufendem Generator: Alle 64 Paare landeten auf derselben EU, verteilt über 58 verschiedene EUs. Alle 160 EUs erhielten Pakete, je 2,23 bis 2,66 Mio. bei einem Durchschnitt von 2,45 Mio.

### Warum RSS und keine Port-Regeln

Naheliegend wäre, eine Regel pro Port-Kombination anzulegen und die EU aus `sport ^ dport` zu berechnen. Auf dieser SF scheitert das an der Regelanzahl:

- Regeln in der Root-Tabelle (Level 0) sind einzelne Firmware-Kommandos, etwa 700 pro Sekunde. 8 Bit je Port ergeben 65536 Regeln und damit rund 100 s Startzeit.
- Tabellen ab Level 1, die Software Steering schnell beschreiben könnte, lehnt die SF mit `Operation not supported` ab.
- Weniger Port-Bits helfen nicht: Der Generator sendet fest an Port 80. Bei 6 Bit je Port gäbe es dann nur 64 mögliche Ziele für 160 EUs.

RSS braucht dagegen nur eine einzige Regel.

## Teil 2: Was der Host anlegen muss

### Einmalig pro Programmlauf

Diese Objekte legt `main` beziehungsweise `steer_flows` an:

| Komponente | Aufruf | Zweck |
|---|---|---|
| IB-Kontext | `open_ibv("mlx5_2")` | Zugang zur SF, alle weiteren Objekte hängen daran |
| Protection Domain | `ibv_alloc_pd` | Schutzbereich, in dem Mkey und RQ zusammengehören |
| FlexIO-App | `flexio_version_set`, `flexio_app_get` | findet den in `device_prog.a` eingebetteten DPA-Code `huginn_app` |
| FlexIO-Prozess | `flexio_process_create` | lädt den Code auf die DPA und stellt den DPA-Heap bereit |
| Nachrichtenstrom | `flexio_msg_stream_create` | leitet Ausgaben der DPA nach `stdout` |
| Flow-Tabelle | `flexio_buf_dev_alloc`, `flexio_buf_dev_memset` | `2^LOG_FLOW_ENTRIES` Einträge auf dem DPA-Heap, genullt, von allen EUs gemeinsam genutzt |

Dazu kommt das Steering, das erst ganz am Ende entsteht:

| Komponente | Aufruf | Zweck |
|---|---|---|
| Transport Domain | DevX `ALLOC_TD` | Pflichtobjekt für den TIR |
| RQT | DevX `CREATE_RQT` | Tabelle der 160 RQs |
| RSS-TIR | DevX `CREATE_TIR` | Hash-Verteilung über die RQT |
| DR-Domain und Tabelle | `mlx5dv_dr_domain_create`, `mlx5dv_dr_table_create` | Steering-Bereich NIC_RX, Root-Tabelle |
| Actions, Matcher, Regeln | siehe Schritt 2 | leiten Pakete an die TIRs |

### Einmal pro EU: `create_handler`

Für jede der 160 EUs entsteht ein eigener, kompletter Empfangspfad. Die Queues und Puffer liegen im DPA-Speicher, damit die NIC und die EU direkt darauf arbeiten. `to_dpa` kopiert dazu vorbereitete Daten vom Host auf den DPA-Heap und gibt die DPA-Adresse zurück.

Die Reihenfolge ergibt sich daraus, wer wen referenziert.

**1. Event Handler: der Thread, der später die Pakete bearbeitet.** Er wird nur angelegt und läuft noch nicht.

```c
struct flexio_event_handler_attr eh_attr = {
	.host_stub_func = pkt_handler,
	.affinity = { .type = FLEXIO_AFFINITY_STRICT, .id = eu },
};
DOCA_TRY(flexio_event_handler_create(proc, &eh_attr, &eh));
```

`pkt_handler` ist auf dem Host nur ein Schlüssel für die Funktion auf der DPA, siehe [dpa_binary_aufbau.md](dpa_binary_aufbau.md).

**2. CQ-Ring und CQ-Doorbell.** Alle CQEs starten mit Owner-Bit 1:

```c
for (uint32_t i = 0; i < Q_DEPTH; i++)
	mlx5dv_set_cqe_owner(&cqes[i], 1);
```

`pkt_handler` hält einen CQE für neu, wenn sein Owner-Bit dem Phasenbit `(cq_ci >> LOG_Q_DEPTH) & 1` entspricht. Das Phasenbit startet bei 0, also gilt am Anfang kein CQE als neu. Nach jedem Umlauf des Rings wechselt das Phasenbit.

**3. CQ.** `FLEXIO_CQ_ELEMENT_TYPE_DPA_THREAD` und `.thread` binden die CQ an den Thread aus Schritt 1, ein neuer CQE weckt also direkt diesen Thread. `.uar_id` nennt die Doorbell-Seite, die zum Armen der CQ gebraucht wird.

**4. RX-Puffer und Mkey.** Pro EU gibt es `Q_DEPTH` = 128 Puffer mit je `BUF_BSIZE` = 2048 Byte, also 256 KiB, bei 160 EUs insgesamt 40 MiB. Der Mkey mit `IBV_ACCESS_LOCAL_WRITE` erlaubt der NIC, per DMA in diesen Bereich zu schreiben.

**5. WQEs.** Jeder WQE zeigt fest auf einen Puffer. Weil diese Zuordnung sich nie ändert, reicht später der Index aus dem CQE, um den Puffer zu finden.

```c
mlx5dv_set_data_seg(&wqes[i], BUF_BSIZE, flexio_mkey_get_id(mkey), ctx.rx_bufs + i * BUF_BSIZE);
```

**6. RQ.** `flexio_rq_create` verknüpft den WQE-Ring und die RQ-Doorbell mit der CQ aus Schritt 3. FlexIO legt dazu den direkten TIR an, den `flexio_rq_get_tir` liefert.

**7. Puffer freigeben.** Erst dieser Schreibzugriff auf die RQ-Doorbell sagt der NIC, dass 128 WQEs bereitstehen:

```c
dbr[0] = htobe32(Q_DEPTH); /* receive counter = number of posted WQEs */
DOCA_TRY(flexio_host2dev_memcpy(proc, dbr, sizeof(dbr), ctx.rq_dbr));
```

**8. Kontext kopieren und Thread starten.** `struct pkt_ctx` bündelt alle DPA-Adressen und Nummern, die `pkt_handler` braucht. Der Host kopiert die Struktur auf die DPA und übergibt ihre Adresse als Argument:

```c
flexio_uintptr_t ctx_daddr = to_dpa(&ctx, sizeof(ctx));
DOCA_TRY(flexio_event_handler_run(eh, ctx_daddr));
```

Dass das erst am Ende passiert, ist Absicht: Die Kopie auf der DPA muss alle zuvor ermittelten Werte enthalten, etwa `cq_num` und `rq_dbr`.

### Abhängigkeiten auf einen Blick

```
Prozess
  ├─ Flow-Tabelle ─────────────────────────────┐
  └─ pro EU:                                   │
       Event Handler ─→ CQ ─→ RQ ─→ Kontext (pkt_ctx) ─→ Thread läuft
                               ▲
              RX-Puffer → Mkey → WQEs
                               │
                alle RQs ─→ RQT ─→ RSS-TIR ─→ Steering-Regeln
```

Die Steering-Regeln kommen zuletzt. Sobald sie stehen, fließen Pakete, und zu diesem Zeitpunkt müssen alle Threads bereits laufen und alle Puffer bereitstehen.

### Was der Host danach noch tut

Nach dem Aufbau läuft auf dem Host nur noch die Messschleife. Sie ruft per RPC (`read_u64` beziehungsweise `flow_table_fill`) die Zähler aus jedem `pkt_ctx` ab. `ctx[eu]` ist die DPA-Adresse des Kontexts, `offsetof` liefert das Feld darin:

```c
count += dpa_u64(ctx[eu] + offsetof(struct pkt_ctx, count));
```

## Stellschrauben und Grenzen

| Stelle | Bedeutung |
|---|---|
| `NUM_CORES`, `EUS_PER_CORE` | Anzahl der genutzten EUs, wirkt auf Handler und RQT |
| `RQT_SIZE` | höchstens 2048, größere Werte lehnt die Firmware mit `BAD_PARAM` ab |
| `LOG_Q_DEPTH`, `BUF_BSIZE` | Tiefe der Queues und Puffergröße pro EU |
| `LOG_FLOW_ENTRIES` | Größe der gemeinsamen Flow-Tabelle |

- **EU 0 trägt allen Nicht-TCP-Verkehr.** Bei viel UDP wird sie zum Engpass, während die anderen EUs nichts davon sehen.
- **Nur IPv4/TCP wird per RSS verteilt.** Auch `parse_five_tuple` geht von IPv4 aus. Das Verhalten bei IPv6 ist nicht getestet.
- **Der Mirror liefert nur eine Richtung.** `setup_dpa.sh` setzt `select-src-port=p0`, es kommt also nur an, was auf `p0` empfangen wird. Für echten Rückverkehr bräuchte es zusätzlich `select-dst-port=p0`.
