# gdb_timeout – lassen sich mit einer gdb-Session länger laufende RPCs ausführen?

Angelegt mit `tools/flexio-template` (`flexio-template --name gdb_timeout`).
Ziel: herausfinden, ob ein angehängter `dpa-gdbserver` den Timeout umgeht, damit
`flexio_process_call()`-RPCs länger als ein paar Sekunden laufen können.

Setup: BF3, DOCA 3.4 / FlexIO 26.04, Gerät `mlx5_0` (keine dpaeumgmt-Partition aktiv).

## Was hier eigentlich das Limit ist

Es gibt zwei Kandidaten:

| Limit | Wo | Wert |
|---|---|---|
| RPC-Poll-Timeout | **Host**, libflexio `unpacked_process_call` (flexio.c:700–740) | 600 × `usleep(10 ms)` ≈ **6 s** |
| `flexio_process_thread_cont_run_time_max_get()` | Device-Watchdog | **100 s** |

Der RPC scheitert am **Host-Timeout** (`Timeout on RPC polling`, `FLEXIO_STATUS_TIMEOUT` = -2).
Der DPA-Thread läuft danach weiter: Der Prozess nimmt weiterhin RPCs an, und `dev_elapsed`
zählt weiter hoch.

Wenn der Poll-Zähler abläuft, prüft libflexio (aus dem Disassembly) einen SysV-Semaphor,
den `dpa-gdbserver` anlegt. Sein Key sind die **unteren 32 Bit des udbg-Tokens**
(`flexio_process_udbg_token_get`):

| Semaphor-Wert | Bedeutung (gdbserver) | libflexio |
|---|---|---|
| fehlt | nicht verbunden | Timeout |
| 1 | Target **halted** | Poll neu starten → wartet unbegrenzt |
| 2 | Target **running** | Poll neu starten, nur wenn `sem_ctime` ≤ 5 s alt ist, sonst Timeout |

Allein „gdb ist angehängt" reicht also nicht. Weiter gewartet wird nur, solange der
Debugger das Target hält oder es in den letzten 5 s angehalten bzw. fortgesetzt hat.

## Ergebnisse (`results/`, erzeugt mit `./run_all.sh`)

Busy-Loop `spin(T)` ohne yield. `wall` = Dauer von `flexio_process_call` auf dem Host.

| Lauf | Bedingung | T | Status | wall |
|---|---|---|---|---|
| `nogdb` | kein gdb | 5 s | OK | 5,0 s |
| `nogdb` | kein gdb | 30 s | **TIMEOUT** | 6,0 s |
| `gdb_attach_30` | gdb angehängt, nur `continue` | 30 s | **TIMEOUT** | 6,0 s |
| `gdb_irq20_30` | gdb, ^C alle 20 s | 30 s | **TIMEOUT** | 6,0 s (vor dem 1. ^C) |
| `gdb_irq3_30` | gdb, ^C alle 3 s für 0,2 s | 30 s | OK | 30,0 s |
| `gdb_bp_30` | gdb, Breakpoint auf `gdb_tick` (alle 100 ms) | 30 s | OK | 30,0 s (300 Hits) |
| `gdb_bp_130` | wie oben | 130 s | OK | 130,0 s (1300 Hits) |
| `fake_30_95` | **kein gdb**, Semaphor selbst auf 1 gesetzt (`-f`) | 30 s / 95 s | OK | 30,0 / 95,0 s |
| `fake_130` | wie oben | 130 s | OK | 130,0 s |

Fazit:

1. **Ja, eine gdb-Session kann den Timeout umgehen – aber nur, wenn das Target
   regelmäßig angehalten wird** (Breakpoint oder ^C in Abständen < ~5 s). Ein gdb, der
   nur angehängt ist und das Target laufen lässt, ändert nichts.
2. **gdb ist dafür gar nicht nötig.** Es reicht, den UDBG-Semaphor
   (`semget(token & 0xffffffff)`) mit Wert 1 anzulegen (`./gdb_timeout -f`). Damit
   wartet libflexio unbegrenzt, ohne dass das Target je angehalten wird und ohne
   gdb-Overhead. Das ist undokumentiertes Verhalten von libflexio 26.04 und kann sich
   mit jeder Version ändern.
3. Das **100-s-Limit `cont_run_time_max` wurde nicht durchgesetzt**: Ein 130-s-Busy-Loop
   ohne yield lief bis zum Ende, ohne gdb (`fake_130`) und mit gdb (`gdb_bp_130`). In
   `dmesg` gab es keine DPA-Meldungen.
4. Nach einem Host-Timeout läuft der RPC-Thread auf der DPA weiter und belegt seine EU.
   Das Ergebnis geht verloren, weil libflexio die RPC-CQ bereits abgeräumt hat.

## Dateien

- `long_rpc.c`: **minimales Beispiel** für einen RPC ohne 6-s-Limit (`make long_rpc && ./long_rpc 30`).
- `device/kernel.c`: `spin(usec, res_daddr)` (rdtime-Busy-Loop, ruft alle 100 ms
  `gdb_tick()` auf) und `read_u64()`, um das Ergebnis-Struct auszulesen (FlexIO hat
  kein dev→host-memcpy).
- `host.c`: `./gdb_timeout [-d dev] [-w] [-f] <sekunden>...`
  - `-w`: Token ausgeben und auf eine Zeile auf stdin warten, um vorher gdb anzuhängen
  - `-f`: Fake-Semaphor ohne gdb
- `rsp.py`: minimaler GDB-Remote-Protocol-Client (Modi `attach`, `interrupt`, `bp`,
  `halt`). Auf dem BF3 gibt es nur einen aarch64-gdb und kein `gdb-multiarch` für
  RISC-V. Außerdem braucht das Experiment exaktes Timing.
- `run_gdb.sh`: startet Host, `dpa-gdbserver` und `rsp.py`, räumt den Semaphor danach
  auf (gdbserver lässt ihn liegen).
- `tick_addr.sh`: Adresse von `gdb_tick` aus dem Device-ELF.
- `run_all.sh`: komplette Messreihe (~8 min).

## Hinweise zu dpa-gdbserver

- Aufruf: `dpa-gdbserver mlx5_0 -T <udbg_token> -s 1981 [-E <eu>]`. Der Server belegt
  selbst eine EU (Default 29) mit einem Device-Handler.
- Continue braucht eine Thread-ID: `vCont;c:p01.-1`. Ein nacktes `vCont;c` lässt den
  Server abstürzen (`GDBS:1281 Expression "args[1] == ':'" failed`). Danach bleibt der
  Semaphor auf seinem letzten Wert stehen.
- Nach einem Breakpoint-Hit muss der Client wie gdb vorgehen (Breakpoint entfernen,
  Single-Step, wieder setzen), sonst trifft der Thread sofort wieder das `ebreak`.
- Interaktiv mit gdb-multiarch (nicht installiert):
  `set architecture riscv:rv64`, `target extended-remote :1981`, `file <device-elf>`
  (Device-ELF mit `dpacc-extract gdb_timeout -o dev.elf -mcpu=nv-dpa-bf3`).
