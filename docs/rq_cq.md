# RQ und CQ

## Wer macht was?

| | Schreibt | Liest | Inhalt |
|---|---|---|---|
| **RQ** | Software (DPA) | NIC | Zeiger auf freie Puffer |
| **RX-Puffer** | NIC | Software | das eigentliche Paket |
| **CQ** | NIC | Software | Meldung „Puffer *i* gefüllt, Länge *n*“ |

```
RQ:   [→Puf0] [→Puf1] [→Puf2] ...     (Zeiger)
Puf:  [Paket] [Paket] [ frei] ...     (Daten)
CQ:   [WQE 0, 64 B] [WQE 1, 1500 B]   (Meldungen)
```

Das Paket liegt also weder in der RQ noch in der CQ, sondern im Puffer. Über den Index im CQE (`wqe_counter`) findet man den Puffer.

## Warum zwei getrennte Queues?

- **Jede Queue hat nur einen Schreiber**, deshalb braucht man keine Locks zwischen NIC und Software.
- **Puffer werden vorher bereitgestellt**, die Metadaten (Länge, Checksumme, Hash, …) entstehen erst nachher.
- **Mehrere Queues können eine CQ teilen.** Events hängen an der CQ, also gibt es nur eine Stelle zum Pollen.

## Warum heißt sie „Completion“ Queue?

Der Name kommt aus InfiniBand und beschreibt die Sicht der **NIC**. Die Software gibt der NIC Aufträge, und die NIC meldet, wenn sie einen erledigt hat:

| Queue | Auftrag | „Completed“ heißt |
|---|---|---|
| SQ | „Sende diesen Puffer“ | Paket ist raus |
| RQ | „Empfange in diesen Puffer“ | Puffer ist gefüllt |

Fertig ist also der **Empfang durch die NIC**, nicht die Verarbeitung. Ab dem CQE ist die Software dran.
