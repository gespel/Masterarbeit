# DPA-Assembly kurz erklärt

`dev.asm` ist das Disassembly von `dev.elf` (Device-Code dieses Experiments). Der BF3-DPA ist
ein RISC-V-Kern, **rv64imac** plus Bit-Manipulation (Zbb, Zbs, Zbkb, Zbp-Draft). Er hat
keine Float-Einheit und kein LR/SC, Atomics gibt es nur als AMO.

Notation: `rd` = Zielregister, `rs1/rs2` = Quellregister, `imm` = Konstante.
Ein `w`-Suffix heißt: Es wird nur mit den unteren 32 Bit gerechnet, das Ergebnis wird
auf 64 Bit vorzeichenerweitert. *Pseudo* = Assembler-Alias für einen anderen Befehl.

## Beispiel: `busy_us`

```
rdtime  a1              # t0 = Zeit in µs (1 MHz)
rdtime  a2              # loop: now
sub     a2, a2, a1      #   now - t0
bltu    a2, a0, loop    #   solange < usec (a0 = 1. Argument)
rdtime  a0
sub     a0, a0, a1      # Rückgabewert in a0
ret
```

## Befehle in `dev.asm`

| Befehl | Bedeutung |
|---|---|
| **Laden / Speichern** | |
| `ld` / `lw` / `lh` / `lb` | 64/32/16/8 Bit laden, vorzeichenerweitert |
| `lwu` / `lhu` / `lbu` | 32/16/8 Bit laden, mit Nullen erweitert |
| `sd` / `sw` / `sh` / `sb` | 64/32/16/8 Bit speichern |
| **Konstanten / Adressen** | |
| `li rd, imm` | Konstante laden (*Pseudo*) |
| `lui rd, imm` | `imm << 12` laden (obere 20 Bit) |
| `auipc rd, imm` | `pc + (imm << 12)`, für PC-relative Adressen |
| `mv rd, rs` | Register kopieren (*Pseudo*: `addi rd, rs, 0`) |
| **Arithmetik** | |
| `add` / `addi` / `addw` / `addiw` | Addition (Register / Konstante / 32 Bit) |
| `sub` / `subw` | Subtraktion |
| `neg` / `negw` | Negation (*Pseudo*: `0 - rs`) |
| `mul` / `mulw` | Multiplikation, untere 64/32 Bit |
| `mulhu` | obere 64 Bit von unsigned × unsigned (z. B. Division durch Konstante) |
| `divu` | unsigned Division (~70 Takte, deshalb selten) |
| **Logik / Shifts** | |
| `and` / `or` / `xor` (+ `i`) | bitweise UND/ODER/XOR |
| `not` | bitweise Negation (*Pseudo*: `xori rd, rs, -1`) |
| `andn` / `orn` | `rs1 & ~rs2` / `rs1 \| ~rs2` (Zbb) |
| `sll` / `srl` / `srai` (+ `i`, `w`) | Shift links / rechts logisch / rechts arithmetisch |
| **Vergleiche** | |
| `slt` / `sltu` (+ `i`) | `rd = (rs1 < rs2)` signed/unsigned |
| `seqz` / `snez` | `rd = (rs == 0)` / `(rs != 0)` (*Pseudo*) |
| `min` / `max` / `minu` / `maxu` | Minimum/Maximum signed/unsigned (Zbb) |
| **Bit-Manipulation** | |
| `zext.b` / `zext.h` / `zext.w` | untere 8/16/32 Bit, mit Nullen erweitert |
| `sext.b` / `sext.h` / `sext.w` | untere 8/16/32 Bit, vorzeichenerweitert |
| `bset` / `bseti` | einzelnes Bit setzen (Zbs) |
| `bext` / `bexti` | einzelnes Bit auslesen → 0/1 (Zbs) |
| `pack rd, rs1, rs2` | untere Hälften von `rs1` und `rs2` zusammenfügen (Zbkb) |
| `rev8` | Byte-Reihenfolge der 64 Bit umdrehen (Endian-Swap) |
| `rev8.w` / `greviw …, 0x18` | Bytes innerhalb 32 Bit umdrehen (`be32_to_cpu`, Zbp) |
| **Sprünge / Verzweigungen** | |
| `beq` / `bne` | springen, wenn gleich / ungleich |
| `blt` / `bge` / `bltu` / `bgeu` | springen bei `<` / `>=`, signed/unsigned |
| `beqz` / `bnez` / `bltz` / `bgez` / `blez` / `bgtz` | Vergleich mit 0 (*Pseudo*) |
| `j` / `jr` | unbedingter Sprung zu Label / Registeradresse |
| `jal` / `jalr` | Funktionsaufruf (Rücksprungadresse in `ra`) |
| `ret` | Rückkehr aus der Funktion (*Pseudo*: `jalr zero, 0(ra)`) |
| **Atomics** | |
| `amoswap.w.aqrl` | atomar tauschen, mit Acquire/Release-Ordnung (z. B. Lock) |
| `amoadd.w.aqrl` | atomar addieren, alten Wert zurückgeben |
| **Ordnung / System** | |
| `fence w, w` | Schreibzugriffe davor vor allen danach sichtbar (`__dpa_thread_fence`) |
| `fence io, io` / `rw, w` / `r, r` | Ordnung für MMIO (Doorbells) bzw. andere Kombinationen |
| `rdtime` | Wall-Clock in µs (1 MHz, `__dpa_thread_time`) |
| `rdcycle` | Taktzähler des Threads (1,8 GHz, `__dpa_thread_cycles`) |
| `rdinstret` | Anzahl ausgeführter Befehle |
| `ecall` | Aufruf ins DPA-Laufzeitsystem (z. B. `thread_finish`, Print) |
| `ebreak` | Breakpoint/Trap (Abbruchpfad, gdb) |

Die Register folgen der RISC-V-ABI: `a0–a7` sind Argumente und Rückgabewert, `s0–s11` werden
vom Aufgerufenen gesichert, `t*` sind temporär, dazu `ra` (Rücksprungadresse), `sp` (Stack)
und `gp` (Global Pointer).
