# Masterarbeit: Idee
- Zweistufiges Vorgehen: 
1. Vorselektieren von interessanten Paketen auf der DPA, 
2. Klassifikation der selektierten Pakete auf der DPA

- Vorselektieren von interessanten Paketen auf der DPA. Dazu Flow based Packet counting nach bestimmbaren Schlüssel wie beispielsweise IP-Adressen, Ports oder Protokollen oder Packet/s Rate. Alternativ auch ultra kleine ML Modelle, die auf der DPA laufen und die Pakete klassifizieren.
Grundsätzlich gilt mehr Pakete sind besser, da so das kaskadierte ML Modell auf dem ARM zusätzlich auch live refined werden kann.

- destilled anomaly Model (?)

- Auf den ARM-Cores der DPA läuft ein ML-Modell, das die selektierten Pakete klassifiziert. Der Austausch der Selektion funktioniert Adressen basiert im shared Memory. Es wird kein Speicher kopiert, sondern nur Adressen ausgewählt. Die DPA wählt so Pakete aus deren Adressen dann dem ARM übergeben werden. Das ML-Modell auf dem ARM kann dann die Pakete klassifizieren und ggf. auch live weiter trainiert werden.
