# Paket-Ablauf in `simple_packet_fetch`

```
Wire → OVS-Mirror → SF mlx5_2 → Steering-Regel → TIR → RQ → RX-Puffer
     → CQE in CQ → Event → DPA-Thread → zählen → Puffer zurückgeben → CQ armen
```

Alles (Queues, Puffer, Zähler) liegt im DPA-Speicher. Die Arm-Kerne fassen das Paket nie an.

1. **Mirror**: OVS kopiert jedes Paket auf das SF `mlx5_2`.
2. **Steering**: Eine Match-all-Regel schickt das Paket an den **TIR**. Der zeigt auf genau eine **RQ**.
3. **RQ** (128 Einträge): Eintrag *i* zeigt fest auf den 2-KB-Puffer *i*. Die NIC schreibt das Paket per DMA in den nächsten freien Puffer.
4. **CQ** (128 Einträge): Danach schreibt die NIC einen **CQE** mit Pufferindex und Länge. Am Owner-Bit erkennt der DPA, ob der CQE neu ist.
5. **Event**: Die CQ ist direkt an einen DPA-Thread gebunden, ohne Interrupt an eine CPU. Ein neuer CQE weckt `pkt_handler`.
6. **DPA** bearbeitet in einer Schleife alle neuen CQEs. Pro Paket:
   - Header aus dem Puffer lesen, Zähler erhöhen
   - **CQ-Doorbell**: „CQE gelesen“ (Consumer Index +1)
   - **RQ-Doorbell**: „Puffer wieder frei“ (Producer Index +1)
7. **Re-arm**: Die CQ wird wieder scharf geschaltet („weck mich beim nächsten CQE“), danach schläft der Thread.
8. **Host**: Liest jede Sekunde per RPC die Zähler aus.

| Begriff | Bedeutung |
|---|---|
| RQ | Receive Queue: Liste freier Empfangspuffer |
| CQ / CQE | Completion Queue / Eintrag: „Paket ist angekommen“ |
| TIR | Ziel einer Steering-Regel, verweist auf die RQ |
| Doorbell | Zähler im Speicher, über den DPA und NIC sich gegenseitig den Fortschritt melden |
