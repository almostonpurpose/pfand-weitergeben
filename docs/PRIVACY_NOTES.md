# Datenschutznotizen für den lokalen Prototyp

## Foto-Schätzung

- Kameraaufnahmen und über den Apple Photo Picker gewählte Bilder werden nur im Arbeitsspeicher verarbeitet.
- Die Auswertung verwendet Apples Vision-Framework auf dem Gerät. Das Bild wird weder hochgeladen noch im Angebot oder in einer Datei gespeichert.
- Das Ergebnis ist ein grober, bearbeitbarer Startwert. Die Person muss Anzahl und Pfandwert selbst prüfen.
- Bei fehlender Kamera, verweigerter Berechtigung, nicht lesbarem Bild oder fehlgeschlagener Vision-Auswertung bleiben die manuellen Felder nutzbar.
- Eine spätere Speicherung, Übertragung oder serverseitige Bildanalyse wäre eine neue Produkt- und Datenschutzentscheidung und ist nicht durch diesen Prototyp abgedeckt.

## Standort und Karten

- Die App fordert keine Standortberechtigung an und liest keinen Gerätestandort.
- Angebotspunkte sind fest eingebaute, ungefähre Demo-Koordinaten. Eine exakte Wohnadresse ist nicht Teil des öffentlichen Datenmodells.
- Die eingebauten Supermarkt- und Glascontainerpunkte sind ausdrücklich bezeichnete Berliner Beispieldaten. Sie sind weder vollständig noch eine Aussage zu Annahmeumfang, Öffnungs-, Leerungs- oder Echtzeitstatus.
- MapKit kann Kartenkacheln und zugehörige Systeminhalte nach Apples Regeln laden. Die App sendet keine Fotos oder Angebotsdaten an einen eigenen Dienst.
- Eine Produktionsquelle für Rückgabestellen muss nachweislich lizenziert sein. Quellenangabe, Lizenzbedingungen, Datenalter, Aktualisierung und bekannte Qualitätsgrenzen müssen erhalten und in App/Datenschutzerklärung beschrieben werden; der Provider darf diese öffentlichen POIs nicht mit privaten Übergabekoordinaten vermischen.

## Lokale Daten

- Angebote und Statusänderungen existieren nur im Arbeitsspeicher und gehen beim Neustart verloren.
- Es gibt im Prototyp keine Konten, Analyse-SDKs, Tracker, Push-Tokens oder eigenen Netzwerkendpunkte.
- Das Datenschutzmanifest erklärt deshalb keine Datenerhebung und kein Tracking. Vor jeder Distribution müssen Implementierung, App-Store-Angaben und diese Notizen erneut gegeneinander geprüft werden.
