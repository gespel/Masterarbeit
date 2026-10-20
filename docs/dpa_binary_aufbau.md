# Aufbau und Build einer DOCA-DPA-Anwendung

Beispiel: [`experiments/rpc_dpa_bench`](../experiments/rpc_dpa_bench/) · DOCA 3.4.0112 · BlueField-3 B3210E.
Alle Zahlen stammen aus einem Build mit `dpacc -keep-dir` und einem Laufzeit-Trace der Verbs-/DevX-Aufrufe (20.10.2026).

## Kurzfassung

- Eine DPA-Anwendung ist **ein einziges AArch64-Programm** für die Arm-Cores der BlueField. Der DPA-Code steckt darin als **eingebettete RISC-V-ELF**, eine pro Zielarchitektur. Er liegt als Byte-Array in der read-only Sektion `.dpa_bin_<app-name>` und wird auf dem Arm nie ausgeführt.
- `dpacc` übersetzt `device/kernel.c` in diese ELFs, erzeugt den Host-Klebecode und packt alles in `device_prog.a`. `gcc` linkt das wie eine normale Bibliothek zu `host.c` dazu.
- Zur Laufzeit lädt `doca_dpa_start()` die zur Hardware passende ELF über die NIC-Firmware in den DPA-Speicher. Kernel-Launches laufen danach ohne Firmware-Kommandos über Queues.

## 1. Build-Pipeline

Der Aufruf im [Makefile](../experiments/rpc_dpa_bench/Makefile) (`dpacc … -mcpu=nv-dpa-bf3,nv-dpa-cx7,nv-dpa-cx8 --app-name=dpa_bench_app`) führt intern diese Schritte aus (sichtbar mit `-dryrun`):

```
device/kernel.c
 │  pro -mcpu (bf3, cx7, cx8) getrennt:
 │   1  dpa-clang -flto -c        → kernel.<arch>.o          LLVM-Bitcode
 │   2  ifgen                     → kernel.dpa.device.c      Unpack-Stubs (DPA-Seite)
 │                                  kernel.dpa.host.c        Pack-Stubs + Registrierung (Host-Seite)
 │   3  llvm-link                 → kernel.<arch>.dpa.join.o Bitcode: Kernel + Unpack-Stubs
 │   4  dpa-clang/ld.lld          → device_exec.<arch>       RISC-V-ELF (LTO-Codegen erst hier)
 │        + dpa_linker.ld, libdoca_dpa_dev, libflexio-dev, flexio-libc
 │  5  dpa-fatbin                 → device_exec.fatbin       alle 3 ELFs in einem Container
 │  6  objproc -emit-as-stub      → device_exec.stub.inc     Fatbin als C-Byte-Array
 │  7  objproc -gen-meta-stub     → dpa_bench_app.meta.c     Konstruktor zur Registrierung
 │  8  gcc, ld -r                 → hostStubs.o              AArch64, enthält alles Obige
 │  9  ar                         → device_prog.a
host.c ── gcc ── + device_prog.a ──→ dpa_bench               AArch64-ELF (PIE)
```

Die wichtigsten generierten Teile:

| Datei | Erzeugt von | Inhalt |
|---|---|---|
| `kernel.dpa.device.c` | `ifgen` | Pro `__dpa_global__`-Funktion ein `_dpacc_flexio_dev_arg_unpack_<kernel>(argbuf, func)`: packt die Argumente aus und ruft den Kernel. Läuft auf der DPA. |
| `kernel.dpa.host.c` | `ifgen` | Pro Kernel eine Pack-Funktion `_dpacc_pack_kernel_<kernel>`, eine **leere schwache Dummy-Funktion** `<kernel>()` und eine Registrierung über `flexio_func_pup_register(app, "hello", "_dpacc_flexio_dev_arg_unpack_hello", hello, …)`. |
| `device_exec.<arch>` | Device-Linker | Vollständiges RISC-V-Programm: Kernels plus DOCA-DPA-/FlexIO-Laufzeit und libc (siehe Abschnitt 3). |
| `device_exec.stub.inc` | `objproc` | Fatbin, Signatur-Slots und Prozessattribute als `const uint8_t[]` mit `__attribute__((section(".dpa_bin_dpa_bench_app")))` usw., dazu die Tabelle `__dpacc_elf_attrs[]` mit {HW-Modell, Zeiger, Größe} je Variante. |
| `dpa_bench_app.meta.c` | `objproc` | `__attribute__((constructor))`, der vor `main()` für jede Variante `flexio_app_create()` und `flexio_app_hw_model_register()` aufruft, die Kernels registriert und die globale Variable `dpa_bench_app` setzt. |

Deshalb funktioniert in [host.c](../experiments/rpc_dpa_bench/host.c) `extern doca_dpa_func_t hello;`: Das Host-Symbol `hello` ist nur die leere Dummy-Funktion und dient als **Schlüssel**. Der echte Code existiert nur in der RISC-V-ELF. `extern struct doca_dpa_app *dpa_bench_app;` ist der vom Konstruktor gesetzte App-Handle.

`bf3` und `cx7` sind dieselbe DPA-Generation. Ihre ELFs unterscheiden sich nur in einem einzigen Byte. `cx8` wird gegen eigene FlexIO-Bibliotheken gelinkt.

## 2. Aufbau des fertigen Binaries `dpa_bench`

`readelf -S -W dpa_bench` (AArch64, PIE):

| Sektion | Größe | Inhalt |
|---|---|---|
| `.text` | 2 824 B | `host.c`, Host-Stubs, Konstruktor |
| `.dpa_bin_dpa_bench_app` | 192 536 B | **DPA-Code**: Fatbin mit 3 RISC-V-ELFs |
| `.dpa_sig_dpa_bench_app` | 196 752 B | Signatur-Slots, hier nur Nullen, d. h. die App ist unsigniert (auf dieser Karte ist `DPA_AUTHENTICATION=False`) |
| `.dpa_proc_attr_dpa_bench_app` | 3 240 B | Prozessattribute je Variante (Kopie von `/opt/mellanox/flexio/lib/dpa-default-process-attributes.bin`) |
| `.data` / `.bss` | – | `__dpacc_elf_attrs[]`, `dpa_bench_app` |

Inhalt von `.dpa_bin_dpa_bench_app`:

```
Offset in der Sektion
 0          Fatbin-Header, Magic "NVDPAFBF", 3 Einträge
 120        device_exec.cx7   64 120 B   RISC-V-ELF
 64 240     device_exec.bf3   64 120 B   RISC-V-ELF   ← wird auf der BF3 geladen
 128 360    device_exec.cx8   64 176 B   RISC-V-ELF
```

Aus Sicht des Arm-Programms ist der DPA-Code also reine Konstante, vergleichbar mit einem eingebetteten Bild. Mit `dpacc-extract dpa_bench -mcpu=nv-dpa-bf3 -o dev.elf` lässt er sich wieder herauslösen (byte-identisch mit `device_exec.bf3`).

## 3. Aufbau der Device-ELF (`device_exec.bf3`)

ELF64 `EXEC`, RISC-V, RVC, Soft-Float-ABI, Entry `0x4000_0000`. Das Layout gibt das Linker-Script `dpa_linker.ld` vor (`code` ab `0x4000_0000`, `sdata` ab `0x8000_0000`, je 128 MB). Alle Adressen sind DPA-seitig:

| Bereich | Adresse | Inhalt |
|---|---|---|
| Code-Segment (R-X) | `0x4000_0000` | `.text` (27 KB), `.rodata`, `.dynsym`, Versions-/Kompatibilitäts-Sektionen |
| Daten-Segment (RW) | `0x8000_0000` | `.got`, `.data`, `.bss`; `gp` zeigt auf `0x8000_0000` |
| Thread-Pointer | `0xb020_0000` | Laufzeitwert (aus einem DPA-Crash-Dump) |
| Stack | `0xc00…` | Laufzeitwert; die Laufzeit legt ihn pro Thread im DPA-Heap an |

Kernel-Symbole (`dpa-nm`): `hello` = `0x4000_1afc`, `calc_primes` = `0x4000_1b0c`, `small_neural_network` = `0x4000_1c0c`, die zugehörigen Unpack-Stubs ab `0x4000_22e4`. Der eigene Code ist nur ein kleiner Teil der 27 KB. Den Rest stellt die mitgelinkte Laufzeit, die ihre internen Funktionen (z. B. `_dpa_start_kernel`, `flexio_hw_rpc`) über denselben Stub-Mechanismus bereitstellt.

## 4. Wie der Code auf die DPA gelangt

Ermittelt per `LD_PRELOAD`-Shim auf `ibv_reg_mr` und `mlx5dv_devx_*`. Die PRM-Opcodes und Objekttypen sind aus den Debug-Infos von `libflexio.so` aufgelöst.

```
Arm: Host-Prozess dpa_bench                     NIC-Firmware / DPA
─────────────────────────────                   ──────────────────
vor main(): Konstruktor
  flexio_app_create() je Variante                (kein Gerätezugriff)
doca_dpa_create(), doca_dpa_set_app()            (kein Gerätezugriff)
doca_dpa_start():
  Gerätefähigkeiten abfragen (QUERY_HCA_CAP)
  BF3-ELF in Heap-Puffer kopieren,
  ibv_reg_mr(64 120 B) + Attribute (1 016 B)
  CREATE_GENERAL_OBJ(DPA_PROCESS) ─────────────→ Loader holt ELF per DMA,
                                                 prüft sie, lädt Segmente
                                                 in den DPA-Speicher
  DPA_WINDOW, DPA_UAR, DPA_OUTBOX,
  DPA_MEM (Heap), 6× DPA_THREAD + CQ/QP/SQ ────→ interne Laufzeit-Threads
doca_sync_event_start(): 1× DPA_THREAD + QP
1. Kernel-Launch: einmalig 2× DPA_THREAD + 2 QP
jeder Launch: Auftrag über Queue ──────────────→ Laufzeit-Thread wird aktiviert:
  (keine Firmware-Kommandos)                     _dpacc_flexio_dev_arg_unpack_hello()
                                                   → hello()
doca_sync_event_wait_gt() ←───────────────────── Sync-Event wird gesetzt
```

Die einzelnen Schritte:

1. **Programmstart:** Der Konstruktor registriert die drei Varianten bei `libflexio`. Die Zeiger zeigen direkt in `.dpa_bin_dpa_bench_app`. Das Gerät wird dabei nicht angesprochen, `doca_dpa_create()` und `doca_dpa_set_app()` ebenfalls nicht.
2. **Auswahl der Variante:** `dpa_bench_app` zeigt formal auf den ersten Eintrag (CX7). Welche ELF geladen wird, entscheidet `libflexio` in `doca_dpa_start()` anhand des Gerätemodells. Der hochgeladene Puffer war byte-identisch mit `device_exec.bf3`.
3. **Upload:** Die ELF wird nicht direkt aus dem Binary übertragen. Sie wird zuerst in einen Heap-Puffer kopiert und dann als Memory Region registriert, damit die NIC per DMA darauf zugreifen kann. Danach folgt das Firmware-Kommando `CREATE_GENERAL_OBJ` mit Objekttyp `DPA_PROCESS`. Laden und Prüfen der ELF erledigt die Firmware, nicht die Host-Bibliothek. `libflexio` kennt dafür die Fehlercodes `ERR_LOADER_ERROR` und `ERR_SIGNATURE_ERROR` für `DPA_PROCESS`.
4. **Ziel im Speicher:** Die DPA hat keinen eigenen DRAM. Ihr Speicher ist ein reservierter Bereich im DDR der BlueField ([Chen et al. 2024](https://arxiv.org/abs/2402.03041); `dpaeumgmt info chip` meldet `heap_max_size: 1073741824`). Code und Daten landen dort unter den virtuellen Adressen aus Abschnitt 3.
5. **Symbolauflösung:** `libflexio` liest die ELF auf dem Host (`elf_get_symbol_info_by_name`) und bildet die registrierten Namen `"hello"` und `"_dpacc_flexio_dev_arg_unpack_hello"` auf DPA-Adressen ab. Der Host-Zeiger `&hello` dient dabei nur als Nachschlageschlüssel.
6. **Kernel-Launch:** Beim ersten `doca_dpa_kernel_launch_update_set()` legt die Laufzeit einmalig Threads und Queues an. In einem Test mit drei aufeinanderfolgenden Launches erzeugten der 2. und 3. Launch **kein einziges Firmware-Kommando**. Der Auftrag (Unpack-Stub, Kernel-Adresse, gepackte Argumente) läuft über die zuvor angelegten Queues. Auf der DPA ruft ein Laufzeit-Thread den Unpack-Stub auf, der den Kernel aufruft. Nach dem Kernel setzt die Laufzeit das beim Launch übergebene Sync-Event, auf das der Host wartet.

Der DPA-Prozess gehört zum Host-Prozess: `doca_dpa_destroy()` bzw. das Programmende räumen ihn wieder ab.

## 5. Nachvollziehen

```bash
DOCA=/opt/mellanox/doca
# interne Build-Schritte anzeigen bzw. Zwischendateien behalten
$DOCA/tools/dpacc device/kernel.c … -dryrun
$DOCA/tools/dpacc device/kernel.c … -keep-dir ./keep

# DPA-Sektionen im Host-Binary
readelf -S -W dpa_bench | grep dpa_

# Device-ELF herauslösen und ansehen
$DOCA/tools/dpacc-extract dpa_bench -mcpu=nv-dpa-bf3 -o dev.elf
readelf -l dev.elf
$DOCA/tools/dpa-objdump -d --mcpu=nv-dpa-bf3 dev.elf
```
