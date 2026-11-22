# Malicious Flows per RDMA zum Host

Wenn das neuronale Netz auf der DPA einen Flow als malicious einstuft, landet der komplette `struct flow` per **RDMA Write** in einem Ringpuffer im Speicher des Host-Prozesses (`huginn` auf dem Arm). Ein Thread auf dem Host liest die Flows dort aus.

Code:

- [huginn/src/common.h](../huginn/src/common.h): Konstanten, `struct malicious_flow_record`, neue Felder in `struct pkt_ctx`
- [huginn/src/device/kernel.c](../huginn/src/device/kernel.c): `mal_report`, `mal_flush`, `sq_post`, `sq_poll`
- [huginn/src/host.c](../huginn/src/host.c): `rdma_env_init`, `setup_mal`, `dpa_qp_connect`, `mal_consumer`

## Warum RDMA und kein FlexIO Window?

Mit einem Window schreibt die DPA selbst, Wort für Wort, über PCIe in den Host-Speicher, und der DPA-Thread wartet bei jedem Store mit. Beim RDMA Write legt die DPA nur einen 64-Byte-Auftrag (WQE) ab und klingelt die Doorbell. Die Daten kopiert danach die NIC per DMA, und der DPA-Thread arbeitet sofort weiter.

Messungen dazu stehen in `VeloxFlowTests/micro_benchmarks/performance/dpamem_bench/RESULTS.md` (BlueField-3, 1 MiB DPA → Arm):

| Weg | Durchsatz |
|---|---|
| Window-Kopie durch die DPA | ~0,3 GB/s |
| RDMA (READ durch den Arm) | ~9,6 GB/s |

Ein RDMA Write, den die DPA selbst postet (der Weg hier), ist dort noch nicht gemessen.

## Überblick

```
                DPA (EU i)                                    Arm (huginn)
 ┌──────────────────────────────────────┐            ┌────────────────────────────┐
 │ infer_flow ─► mal_report             │            │                            │
 │                │ memcpy 76 B          │            │  rings[i]  (ibv_reg_mr)    │
 │                ▼                      │            │  1024 × 128 B              │
 │  Staging-Ring (1024 × 128 B, mkey)    │            │      ▲                     │
 │                                       │            │      │ seq pollen          │
 │ pkt_handler-Ende ─► mal_flush         │            │  mal_consumer (pthread)    │
 │   sq_post: WQE in SQ                  │            │      │                     │
 │   Doorbell ───────────┐               │            │  handle_malicious → stdout │
 │                       ▼               │            └──────▲─────────────────────┘
 │  QP_req (SQ, DPA)   NIC liest WQE +   │                   │
 │                     Staging-Daten     │   RC, Loopback    │ DMA in rings[i]
 │                       └──────────────────► QP_resp ──────┘
 │  SQ-CQ ◄── CQE (jeder 16. WQE)        │   (FlexIO, nur HW)
 └──────────────────────────────────────┘
```

Jede der 176 EUs (11 Kerne × 16) bekommt ihr eigenes Set aus Objekten. Damit hat jeder Ring genau einen Schreiber, und zwischen den EUs braucht es weder Locks noch Atomics.

## Objekte pro EU

| Objekt | Liegt in | Schreibt | Liest | Angelegt in |
|---|---|---|---|---|
| Staging-Ring (`mal_stage`), 1024 × 128 B | DPA-Speicher | DPA (`mal_report`) | NIC (über `mal_lkey`) | `setup_mal` |
| Device-mkey auf dem Staging-Ring | – | – | NIC | `flexio_device_mkey_create` |
| SQ (`sq_ring`), 64 WQEs × 64 B | DPA-Speicher | DPA (`sq_post`) | NIC | `setup_mal` |
| SQ-CQ (`sq_cq_ring`), 64 CQEs | DPA-Speicher | NIC | DPA (`sq_poll`) | `flexio_cq_create` |
| Doorbell-Records (`dbr`, 64 B) | DPA-Speicher | DPA/NIC | NIC/DPA | `setup_mal` |
| Requester-QP (`dqp`) | – | – | – | `flexio_qp_create` mit SQ |
| Responder-QP (`rqp`) | – | – | – | `flexio_qp_create` mit `no_sq = 1` |
| Host-Ring `rings[eu]`, 1024 × 128 B | Arm-Speicher | NIC (über `mal_rkey`) | Arm (`mal_consumer`) | `rdma_env_init` |

Alle Host-Ringe liegen hintereinander in **einem** Speicherblock mit **einer** MR (`env->mr`). EU *i* schreibt ab `rings + i * MAL_RING_SIZE` (`ctx->mal_raddr`).

Die 64 Byte für die Doorbell-Records teilen sich so auf:

| Offset | Inhalt |
|---|---|
| 0 | CQ-Doorbell der SQ-CQ (`sq_cq_dbr`) |
| 16 | WQ-Doorbell der Requester-QP |
| 32 | WQ-Doorbell der Responder-QP |

## Der Record

```c
struct malicious_flow_record {
	struct flow f;        /*   0..75  kompletter Flow           */
	int16_t score;        /*  76..77  out[0] des Netzes         */
	uint16_t eu;          /*  78..79  welche EU                 */
	uint32_t ts;          /*  80..83  __dpa_thread_time()       */
	uint8_t _pad[40];     /*  84..123                           */
	uint32_t seq;         /* 124..127 Sequenznummer, zuletzt    */
} __attribute__((aligned(64)));
```

- **128 Byte**, also genau zwei Cachelines. Die Offsets im Ring sind damit einfache Shifts.
- **`seq` steht am Ende.** Der Host erkennt einen neuen Record daran, dass `seq` den erwarteten Wert hat (siehe [Host](#host-mal_consumer)).
- **Zwei `_Static_assert`s** in `common.h` prüfen `sizeof(struct flow) == 76` und `sizeof(struct malicious_flow_record) == 128`. Host (gcc, aarch64) und DPA (dpacc/clang, RISC-V) kompilieren `common.h` getrennt. Hätten sie ein anderes Layout, würde der Host Müll lesen. So bricht stattdessen der Build ab.

## Setup auf dem Host

### `rdma_env_init` (einmal)

1. **Port und GID abfragen** (`ibv_query_port`, `ibv_query_gid` mit `GID_INDEX = 0`).
2. **Eigene MAC aus der GID ableiten.** Die link-local GID ist eine EUI-64 aus der MAC: Bytes 8–10 und 13–15, Bit 1 von Byte 8 invertiert (`^ 2`).
3. **Host-Ringe anlegen:** `aligned_alloc(4096, 176 × 1024 × 128 B)` (≈ 22 MiB), auf 0 setzen und mit `ibv_reg_mr(..., LOCAL_WRITE | REMOTE_WRITE)` registrieren. `REMOTE_WRITE` braucht es, damit fremde RDMA Writes auf die MR erlaubt sind. Die 0 ist wichtig, denn `seq = 0` bedeutet „nie geschrieben“.

### `setup_mal` (pro EU, aus `create_handler`)

1. **SQ-CQ:** 64 CQEs im DPA-Speicher, alle mit Owner-Bit 1 (wie bei der RX-CQ). Die CQ wird an den Thread der EU gehängt (`FLEXIO_CQ_ELEMENT_TYPE_DPA_THREAD`), aber mit `no_arm = true`. Sie löst also nie selbst einen Handler aus, die DPA pollt sie.
2. **SQ-Ring:** 64 × 64 B im DPA-Speicher.
3. **Requester-QP** (`dqp`): RC, SQ im DPA-Speicher, keine RQ (`ZERO_SIZE_RQ`), SQ-CQ von oben.
4. **Responder-QP** (`rqp`): RC, `no_sq = 1`, keine RQ. Sie hat also keinerlei Queues, nur einen QP-Kontext in der NIC. Ein RDMA Write verbraucht beim Empfänger keinen Receive-WQE und erzeugt dort keinen CQE, also reicht das.
5. **Verbinden** (`dpa_qp_connect`, in beide Richtungen): RESET → INIT → RTR → RTS mit
   - `remote_qp_num` = QP-Nummer der Gegenseite
   - `rgid_or_rip` = **eigene** GID, `dest_mac` = **eigene** MAC, `grh = 1`
   - `fl = 0` (kein Force-Loopback)
   - `path_mtu` = aktive MTU des Ports
6. **Staging-Ring:** 1024 × 128 B im DPA-Speicher, dazu ein Device-mkey (`flexio_device_mkey_create`, `LOCAL_WRITE`). Dessen ID ist `mal_lkey`.
7. **Kontext füllen:** `qp_num`, `mal_lkey`, `mal_rkey = env->mr->rkey`, `mal_raddr`, `eu`.

Danach kopiert `create_handler` den Kontext mit `to_dpa` auf die DPA und startet den Handler.

### Warum diese Verbindungsparameter?

- **Eigene GID/MAC, `fl = 0`:** Das Paket geht an den eigenen Port und wird in der NIC zurückgeführt, ohne das Kabel zu erreichen. Im dpamem-Benchmark hat sich gezeigt: Mit `fl = 1` oder einer MAC von 0 erreicht die QP zwar RTS, aber kein Request wird je abgeschlossen (siehe Kommentar in `dpamem_host.c`, `setup_rdma_write`).
- **`GID_INDEX` muss auf die link-local GID (EUI-64) zeigen**, sonst stimmt die abgeleitete MAC nicht.

### Warum ist der Responder keine ibv-QP auf dem Arm?

Ursprünglich war pro EU eine `ibv_create_qp` auf dem Arm vorgesehen. Ab EU 32 schlug das mit `ENOMEM` fehl. Wahrscheinlich gehen dem ibv-Kontext die UARs/bfregs aus, denn jede Arm-QP mit SQ braucht eine Doorbell-Seite. Eine FlexIO-QP mit `no_sq = 1` braucht auf dem Arm keine Ressourcen.

### Consumer-Thread

Nach `steer_flows` startet `main` den Thread `mal_consumer` mit `pthread_create`.

## Laufzeit auf der DPA

### Indizes

Jede EU verwaltet zwei Gruppen von 32/64-Bit-Zählern. Die Zähler wachsen nur. Erst beim Zugriff auf den Ring wird mit `& MASK` reduziert.

**Records** (Staging-Ring):

```
   mal_acked        mal_posted        mal_pi
       │                 │               │
───────┼─────────────────┼───────────────┼──────────────►
 von NIC gelesen │ gepostet,        │ geschrieben,    │ frei
 (Slot frei)     │ NIC noch nicht   │ noch kein WQE   │
                 │ bestätigt        │                 │
```

| Zähler | Bedeutung | Erhöht in |
|---|---|---|
| `mal_pi` | Anzahl geschriebener Records | `mal_report` |
| `mal_posted` | bis hier sind WQEs gepostet | `mal_flush` |
| `mal_acked` | bis hier hat die NIC gelesen und der Responder bestätigt | `sq_poll` |

Der Ring ist voll, wenn `mal_pi - mal_acked >= MAL_RING_SIZE`.

**Send Queue:**

| Zähler | Bedeutung |
|---|---|
| `sq_pi` | nächster freier WQE-Slot / Wert für die Doorbell |
| `sq_ci` | bis hier sind WQEs abgeschlossen |
| `sq_cq_ci` | nächster erwarteter CQE in der SQ-CQ |
| `sq_rec_end[w]` | `mal_pi`-Stand, den WQE `w` abschließt |

### 1. `mal_report`: Flow in den Staging-Ring

Wird in `infer_flow` aufgerufen, sobald `out[0] > NN_THRESHOLD` gilt, und zwar **vor** `flow_free`:

1. **Voll?** Bei `mal_pi - mal_acked >= 1024` wird zuerst die SQ-CQ gepollt (`sq_poll`), vielleicht ist inzwischen Platz. Ist der Ring dann immer noch voll, gilt `mal_dropped++` und der Flow ist verloren.
2. **Kopieren:** `memcpy` des ganzen `struct flow` (76 B) nach `mal_stage[mal_pi & 1023]`, dazu `score`, `eu`, `ts`.
3. **`seq = mal_pi + 1`** (Record Nummer *n* hat `seq = n + 1`, damit 0 frei bleibt für „leer“), danach `mal_pi++`.

Warum die Kopie nötig ist: `flow_free` gibt den Tabellenslot frei, und `flow_update` kann ihn sofort neu vergeben. Die NIC liest die Daten aber erst später asynchron. Würde der WQE direkt auf den Tabelleneintrag zeigen, käme womöglich ein halb überschriebener Flow beim Host an.

Bis hierher geschieht alles im lokalen DPA-Speicher, ohne PCIe.

### 2. `mal_flush`: alle neuen Records auf einmal posten

Wird **einmal pro `pkt_handler`-Aufruf** aufgerufen, nach `bucket_cleaner` und vor `flexio_dev_cq_arm`. Alle Flows, die in diesem Aufruf malicious waren, gehen dadurch gemeinsam raus.

1. **`sq_poll`**, um abgeschlossene WQEs abzuräumen.
2. **Nichts zu tun** bei `mal_posted == mal_pi`: dann sofort zurück.
3. **SQ fast voll** bei `sq_pi - sq_ci > SQ_DEPTH - 2`: zurück. Die Records bleiben im Staging-Ring und gehen beim nächsten Aufruf raus. Geprüft wird auf 2, weil ein Flush höchstens 2 WQEs braucht.
4. **WQEs bauen:**
   - Liegt der Bereich `[mal_posted, mal_pi)` am Stück im Ring, reicht **ein** `sq_post`.
   - Bricht er am Ringende um, sind es **zwei**: bis zum Ende, dann ab Slot 0. Ein RDMA Write braucht einen zusammenhängenden Quell- und Zielbereich. Weil Staging- und Host-Ring dasselbe Layout haben (Slot *k* → Slot *k*), stimmt das für beide Seiten zugleich.
5. **Fence** `__dpa_thread_fence(__DPA_MEMORY, __DPA_W, __DPA_W)`: WQEs und Staging-Daten müssen im Speicher stehen, bevor die NIC von der Doorbell erfährt.
6. **Doorbell** `flexio_dev_qp_sq_ring_db(sq_pi, qp_num)`: teilt der NIC den neuen Producer-Index der SQ mit.
7. `mal_posted = mal_pi`.

### 3. `sq_post`: ein WQE

Ein WQE belegt einen 64-Byte-Slot (WQEBB) mit 4 Segmenten zu je 16 Byte:

| Segment | Setter | Inhalt |
|---|---|---|
| 0 | `flexio_dev_swqe_seg_ctrl_set` | Opcode `RDMA_WRITE`, WQE-Index `sq_pi`, QP-Nummer, Anzahl Segmente, CQE-Modus |
| 1 | `flexio_dev_swqe_seg_rdma_set` | Zieladresse `mal_raddr + off`, `mal_rkey` |
| 2 | `flexio_dev_swqe_seg_mem_ptr_data_set` | Länge `n × 128`, `mal_lkey`, Quelladresse `mal_stage + off` |
| 3 | – | unbenutzt |

`off = (from & 1023) × 128` ist auf beiden Seiten derselbe Offset.

Außerdem merkt sich `sq_post` in `sq_rec_end[sq_pi & 63]`, bis zu welchem Record dieser WQE reicht. Daraus kann `sq_poll` später `mal_acked` setzen.

**Selective Signaling:** Nicht jeder WQE erzeugt einen CQE. Signalisiert (`CQE_ALWAYS`) wird nur, wenn

- `sq_pi % 16 == 15` (jeder 16. WQE, `SIG_EVERY`), **oder**
- `end - mal_acked >= 512` (mehr als ein halber Ring ist unbestätigt).

Alle anderen WQEs laufen mit `CQE_ON_CQE_ERROR` und melden sich nur im Fehlerfall. Das spart CQEs und Polling, denn ein CQE für WQE *w* bedeutet: *w* und alle WQEs davor sind fertig. RC-QPs arbeiten der Reihe nach.

Die zweite Bedingung verhindert einen Deadlock bei wenig Verkehr. Ohne sie könnte der Staging-Ring voll laufen, während alle offenen WQEs unsignalisiert sind. Dann käme kein CQE, `mal_acked` bliebe stehen, jeder neue Flow würde verworfen, und es gäbe nichts mehr zu posten, was signalisiert werden könnte.

### 4. Was die NIC macht

1. Sie liest den WQE aus der SQ im DPA-Speicher.
2. Sie liest `n × 128` Byte aus dem Staging-Ring (über `mal_lkey`).
3. Sie schickt sie als RDMA-Write-Pakete an die Responder-QP. Das Ziel ist die eigene GID/MAC, also bleibt das Paket in der NIC (Loopback).
4. Der Responder prüft `mal_rkey` gegen die MR und schreibt per DMA in den Host-Ring. Danach schickt er ein ACK.
5. Nach dem ACK schreibt die Requester-Seite (nur bei signalisierten WQEs) einen CQE in die SQ-CQ.

Dass ein CQE da ist, bedeutet also: Die Daten stehen im Host-Speicher, **und** die NIC braucht die Staging-Slots nicht mehr.

### 5. `sq_poll`: Completions abräumen

Die SQ-CQ wird gepollt wie die RX-CQ in `pkt_handler`. Ein CQE ist gültig, wenn sein Owner-Bit gleich `(sq_cq_ci >> LOG_SQ_DEPTH) & 1` ist. Für jeden gültigen CQE:

1. **Fehler?** Opcode `>= 0xd` (Requester- oder Responder-Fehler) zählt `sq_errors++`. Nach einem Fehler geht die QP in den Zustand ERR, und alle weiteren WQEs scheitern ebenfalls.
2. **`wqe_counter`** (16 Bit) ist der Index des abgeschlossenen WQE. `sq_ci += (uint16_t)(wc + 1 - (uint16_t)sq_ci)` macht daraus den 32-Bit-Zähler, auch über den 16-Bit-Überlauf hinweg.
3. **`mal_acked = sq_rec_end[wc & 63]`**: Die Staging-Slots bis dahin sind wieder frei.
4. `sq_cq_ci++`.

Am Ende wird die CQ-Doorbell (`flexio_dev_dbr_cq_set_ci`) einmal gesetzt, damit die NIC die CQE-Slots wiederverwenden darf.

Die CQ hat so viele Einträge wie die SQ (64). Da höchstens 64 WQEs offen sind, kann sie nicht überlaufen.

## Host: `mal_consumer`

Der Thread läuft in einer Endlosschleife über alle 176 Ringe und hält pro EU einen Lesezähler `ci[eu]`:

```c
r        = &ring[ci & 1023];
expected = ci + 1;
seq      = atomic_load_acquire(&r->seq);
```

| Fall | Bedeutung | Reaktion |
|---|---|---|
| `seq == expected` | neuer Record | `handle_malicious(r)`, `ci++` |
| `seq == 0` | Slot wurde nie beschrieben | weiter zur nächsten EU |
| `seq < expected` | Record aus der vorigen Runde, der neue ist noch nicht da | weiter zur nächsten EU |
| `seq > expected` | die DPA hat den Ring mindestens einmal überrundet | `mal_lost += seq - expected`, `ci` springt nach, Record wird verarbeitet |

Der Vergleich `(int32_t)(seq - expected) < 0` rechnet korrekt über den 32-Bit-Überlauf von `seq`.

Die DPA erfährt **nicht**, wie weit der Host gelesen hat. Ihr einziger Gegendruck ist der Staging-Ring (`mal_acked`). Ist der Host zu langsam, überschreibt die NIC ungelesene Slots. Das sieht man dann in `lost`. Weil der Consumer ununterbrochen pollt (ein Arm-Kern ist voll ausgelastet), sollte das kaum vorkommen.

`handle_malicious` schreibt jeden Flow als eine Zeile auf **stdout**:

```
MAL eu=17 score=812 10.0.0.5:51234 <-> 10.0.0.9:22 proto=6 pkts=8 bytes=1240 len=[60,412] iat=[3,950,210] rst=0 psh=4 fin=0 urg=0
```

Die Statistik geht weiterhin auf **stderr**, so lassen sich beide getrennt umleiten (`./huginn > flows.log`).

## Statistik

`collect_stats` summiert zusätzlich `mal_dropped` und `sq_errors` über alle EUs. Die Ausgabe auf stderr zeigt:

```
rdma to host: <Flows/s> flows/s, lost: <n>, dropped: <n>, rdma errors: <n>
```

| Wert | Quelle | Bedeutung |
|---|---|---|
| `rdma to host` | `mal_received` (Host) | Flows pro Sekunde, die beim Host angekommen sind |
| `lost` | `mal_lost` (Host) | vom Host zu spät gelesen, schon überschrieben |
| `dropped` | `mal_dropped` (DPA) | Staging-Ring war voll, Flow wurde nie gesendet |
| `rdma errors` | `sq_errors` (DPA) | Fehler-CQEs. Ist der Wert > 0, ist die QP kaputt |

## Parameter

| Konstante | Wert | Wirkung |
|---|---|---|
| `LOG_MAL_RING` | 10 | 1024 Records pro EU, je ein Ring im DPA- und im Host-Speicher |
| `LOG_SQ_DEPTH` | 6 | 64 WQEs pro SQ, 64 CQEs pro SQ-CQ |
| `SIG_EVERY` | 16 | jeder 16. WQE erzeugt einen CQE. Muss eine Zweierpotenz und deutlich kleiner als `SQ_DEPTH` sein |
| `GID_INDEX` | 0 | Index der link-local GID von `mlx5_2` |

Speicherbedarf bei 176 EUs:

| | pro EU | gesamt |
|---|---|---|
| Staging-Ring (DPA) | 128 KiB | 22 MiB |
| Host-Ring (Arm) | 128 KiB | 22 MiB |
| SQ + SQ-CQ (DPA) | 4 KiB + 4 KiB | 1,4 MiB |

## Annahmen und Grenzen

- **`seq` kommt zuletzt an.** Der Host liest den Record, sobald `seq` stimmt, und nimmt an, dass die übrigen 124 Byte dann auch schon da sind. Ohne PCIe Relaxed Ordering schreibt die NIC einen RDMA Write der Reihe nach, in der Praxis trifft das zu. Die RDMA-Spezifikation garantiert es aber nicht. Eine strikte Variante wäre `RDMA_WRITE_IMM`: Der Host bekommt pro Write einen CQE, nach dem die Daten sicher vollständig sind. Dafür braucht der Responder eine RQ und der Host eine CQ zum Pollen.
- **Flush nur, wenn Pakete kommen.** `mal_flush` läuft am Ende von `pkt_handler`, und der Handler startet nur, wenn ein Paket in der RX-CQ landet. Kommt nach einem malicious Flow kein Paket mehr auf derselben EU an, bleibt der Record im Staging-Ring liegen, bis das nächste Paket kommt.
- **Eine zweite CQ am Thread.** Die SQ-CQ hängt am selben DPA-Thread wie die RX-CQ, ist aber nie gearmt und löst deshalb nie aus. Das Anlegen funktioniert. Ob es im Betrieb Nebenwirkungen hat, ist ungeprüft.
- **Fehler sind endgültig.** Nach einem Fehler-CQE steht die QP in ERR. Es gibt keine Wiederherstellung, `rdma errors` zählt dann nur noch hoch.

## Stand (2026-11-22)

- Host- und Device-Code kompilieren ohne Warnungen.
- Alle 176 QP-Paare lassen sich anlegen und verbinden.
- Ein Lauf bis zu den ersten Records ist noch nicht gelungen: `huginn` bricht vorher bei `mlx5dv_dr_rule_create` in `steer_flows` ab. Das passiert genauso mit dem unveränderten Stand ohne RDMA und hat mit diesem Code nichts zu tun. Ob die Writes ankommen (`rdma errors: 0`, `MAL`-Zeilen auf stdout), ist daher noch nicht auf der Hardware geprüft.
