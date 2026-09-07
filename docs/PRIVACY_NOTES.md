# Datenschutznotizen für den lokalen Prototyp

## Foto-Schätzung

- Kameraaufnahmen und über den Apple Photo Picker gewählte Bilder werden nur im Arbeitsspeicher verarbeitet.
- Die Auswertung verwendet Apples Vision-Framework auf dem Gerät. Das Bild wird weder hochgeladen noch im Angebot oder in einer Datei gespeichert.
- Das Ergebnis ist ein grober, bearbeitbarer Startwert. Die Person muss Anzahl und Pfandwert selbst prüfen.
- Bei fehlender Kamera, verweigerter Berechtigung, nicht lesbarem Bild oder fehlgeschlagener Vision-Auswertung bleiben die manuellen Felder nutzbar.
- Eine spätere Speicherung, Übertragung oder serverseitige Bildanalyse wäre eine neue Produkt- und Datenschutzentscheidung und ist nicht durch diesen Prototyp abgedeckt.

## Standort und Karten

- Die App fordert keine Standortberechtigung an und liest keinen Gerätestandort.
- Öffentliche Angebotspunkte sind fest eingebaute, ungefähre Demo-Koordinaten. Für Haustürabholung erfasst der lokale Prototyp eine genaue Adresse im Arbeitsspeicher; öffentlich angezeigt wird sie nicht. Nach Annahme sieht sie nur die angenommene Abholung innerhalb dieses lokalen Demo-Zustands.
- Die eingebauten Supermarkt- und Glascontainerpunkte sind ein OpenStreetMap-Snapshot vom 7. September 2026. Sie sind weder vollständig noch eine Aussage zu Annahmeumfang, Öffnungs-, Leerungs- oder Echtzeitstatus.
- MapKit kann Kartenkacheln und zugehörige Systeminhalte nach Apples Regeln laden. Die App sendet keine Fotos oder Angebotsdaten an einen eigenen Dienst.
- Quelle und Lizenzgrenze des Snapshots stehen in `docs/OPEN_DATA.md`. Ein Produktions-Refresh muss Attribution, ODbL, Datenalter und bekannte Qualitätsgrenzen erhalten; der Provider darf diese öffentlichen POIs nicht mit privaten Übergabekoordinaten vermischen.

## Lokale Daten

- Angebote und Statusänderungen existieren nur im Arbeitsspeicher und gehen beim Neustart verloren.
- Es gibt im Prototyp keine Konten, Analyse-SDKs, Tracker, Push-Tokens oder eigenen Netzwerkendpunkte.
- Die Links unter „Hilfe in Berlin“ öffnen Telefon oder Browser nur nach einer ausdrücklichen Berührung. Die App übermittelt dabei selbst keine Profildaten oder Angebotsdaten und löst keinen automatischen Kontakt aus.
- Das Datenschutzmanifest erklärt deshalb keine Datenerhebung und kein Tracking. Vor jeder Distribution müssen Implementierung, App-Store-Angaben und diese Notizen erneut gegeneinander geprüft werden.
