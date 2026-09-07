# Pfand weitergeben

Eine native iPhone-App, über die Nachbar:innen Pfandflaschen unkompliziert weitergeben: Eine Person stellt ein Angebot ein, eine andere nimmt es an, holt die Behälter ab und **behält den vollständigen Pfandbetrag**.

Der aktuelle Stand ist ein polierter, vollständig lokaler Prototyp. Er startet ohne Konto, Server oder Zugangsdaten mit klar gekennzeichneten Demo-Angeboten. Die öffentlichen Rückgabestellen sind dagegen ein lizenzierter OpenStreetMap-Datenschnappschuss für ganz Berlin.

## Öffnen und starten

1. `PfandWeitergeben.xcodeproj` in Xcode öffnen.
2. Das Scheme **PfandWeitergeben** und einen iPhone-Simulator mit iOS 17 oder neuer wählen.
3. Run (`⌘R`) drücken.

Für ein eigenes Gerät unter **Signing & Capabilities** das persönliche Apple-Developer-Team auswählen. Die Bundle-ID kann bei Bedarf geändert werden.

## Enthalten

- Kartenbasierte Angebotssuche mit zugänglicher Listenalternative
- Zwei optionale, klar unterscheidbare Kartenebenen mit 177 realen OpenStreetMap-Standorten für Supermärkte/Pfandrückgabe und öffentliche Glascontainer, jeweils auch als gefilterte Liste und mit Legende
- Angebot erstellen: getrennte Mengen für 8-, 15- und 25-Cent-Pfand, Beutelgröße, 15-Minuten-Zeitfenster, Hinweise und Abholort
- Detailansicht mit gut sichtbarem Pfand-Hinweis und Annahme
- Aktivitätsansicht für `verfügbar → vereinbart → abgeholt` sowie Stornierung
- Sicherheitszentrum, Angebotsmeldung, Gemeinschaftsregeln und Einstellungen
- Vollständige App-Sprache in Deutsch, Englisch, Arabisch und Türkisch; Deutsch ist Standard, Arabisch nutzt RTL-Layout
- In-App-Sprachwahl unter **Einstellungen → Sprache**
- Schnelle lokale Foto-Schätzung per Kamera oder Fotomediathek mit bearbeitbarer grober Gesamtzahl; die Person verteilt sie anschliessend selbst auf 8, 15 und 25 Cent
- Abholung an der Haustür, kontaktlose Ablage vor der Tür oder anderer vereinbarter Ort; die genaue Adresse erscheint erst nach Annahme
- Optionaler Bereich **Hilfe in Berlin** mit 112/110, Kältebus, Kältehilfetelefon, aktuellem Kältehilfe-Wegweiser und Sozialer Wohnhilfe
- Lokaler Demo-Speicher hinter dem `OfferProviding`-Protokoll
- Lizenzierter Berliner OpenStreetMap-Snapshot hinter dem austauschbaren `ReturnPointProviding`-Protokoll
- SwiftUI-Previews, Demo-Daten, Datenschutzmanifest und Unit-Tests

## Architektur und späterer Cloudflare-Dienst

Oberflächen greifen ausschließlich über `OfferProviding` auf Angebote zu. `DemoOfferStore` implementiert diese Grenze im Arbeitsspeicher. Eine Produktionsimplementierung kann dieselben Operationen an eine Cloudflare Worker API senden, ohne den Nutzerfluss neu zu bauen.

Empfohlene Backbone-Komponenten für die Produktionsfassung:

- Cloudflare Worker als authentifizierte API
- D1 für Angebote, Statusereignisse, Reports und Moderationsentscheidungen
- R2 nur falls später Bilder erlaubt werden
- Better Auth auf D1 für Konten und Sitzungen
- exakte Übergabeinformationen serverseitig getrennt speichern und erst für akzeptierte Claims freigeben

Keine Provider-Schlüssel gehören in die App. Der Demo-Build führt keine eigenen Backend- oder Analyseaufrufe aus. MapKit kann Karteninhalte nach Apples Systemregeln laden; Fotos werden davon unabhängig ausschließlich lokal ausgewertet.

## Kartenebenen und Datenquellen

Die beiden optionalen Kartenebenen laden einen mitgelieferten Schnappschuss vom **7. September 2026** mit 177 über Berlin verteilten OpenStreetMap-Standorten: 92 Supermarkt-/Pfandrückgabe-Einträge und 85 Altglasstandorte. Die App zeigt Quelle, Lizenz und Datenalter direkt an.

- Bei 16 Punkten ist in OpenStreetMap ausdrücklich `vending=bottle_return` hinterlegt. Die übrigen Supermarktpunkte belegen nur den Marktstandort; Pfandrücknahme und angenommene Behälter müssen vor Ort geprüft werden.
- Altglaspunkte tragen in OpenStreetMap `recycling:glass_bottles=yes`; sie sind keine Pfandrückgabeautomaten.
- Es werden weder Verfügbarkeit noch Öffnungs- oder Leerungsstatus in Echtzeit behauptet.
- `ReturnPointProviding` trennt die Oberfläche vom Ursprung der Daten. Import, Auswahlgrenze, Attribution und ODbL-Hinweise stehen in [`docs/OPEN_DATA.md`](docs/OPEN_DATA.md).
- Supermarktstandorte dürfen nicht als vollständig bezeichnet werden; Öffnungszeiten dürfen nur angezeigt werden, wenn Quelle und Aktualität dafür belastbar sind.

Das Demo fordert weiterhin keinen Gerätestandort an. Die sichtbaren Rückgabestellen sind öffentliche POIs; sie ändern nichts an der ungefähren Darstellung persönlicher Übergabeorte.

## Foto-Schätzung und Datenschutz

Die Angebotserstellung kann ein Foto aufnehmen oder über Apples systemeigenen Photo Picker auswählen. Eine lokale Vision-Konturanalyse liefert einen bewusst groben Startwert für die Gesamtzahl. Sie erkennt keine Pfandklasse. Die Person verteilt die Menge selbst auf Mehrweg 8 Cent, Mehrweg 15 Cent und Einweg 25 Cent; daraus wird der Wert berechnet.

- Das Foto wird nicht hochgeladen und nicht im Angebot gespeichert.
- Die App behauptet keine genaue Flaschen- oder Pfanderkennung.
- Wenn Kamera, Bild oder Vision-Auswertung nicht verfügbar sind, bleiben die manuellen Felder vollständig nutzbar.
- Die aktuelle Heuristik ist nur für den lokalen Prototyp gedacht und nicht im Feld kalibriert.

Die technischen Datenschutzgrenzen sind in [`docs/PRIVACY_NOTES.md`](docs/PRIVACY_NOTES.md) festgehalten.

## Verwendetes Design-System

Die visuelle Sprache adaptiert **„the next small thing“** aus der lokalen DesignDealer-Bibliothek (`/Users/amr/Developer/designdealer/children/the-next-small-thing`). Übernommen wurden:

- warmer Peach-Grund statt sterilem Weiß
- ruhige Coral-/Sage-Akzente mit warmem Ink
- menschliche Rundungen und großzügige, atmende Abstände
- freundliche, gegenwartsnahe Sprache ohne Gamification
- die „bracket-of-care“-Geste als native SwiftUI-Form bei Abschnittsüberschriften

Die Web-Schriften wurden nicht eingebunden; die App verwendet Dynamic Type-fähige Apple-Systemschriften. Schatten wurden bis auf Kartenmarkierungen vermieden. Damit bleibt die Adaption systemtreu, nativ und barrierearm.

## Tests

In Xcode mit `⌘U` oder auf der Kommandozeile:

```sh
xcodebuild test \
  -project PfandWeitergeben.xcodeproj \
  -scheme PfandWeitergeben \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

Getestet werden Validierung, erlaubte/verbotene Statusübergänge, Foto-Fallback, Pfandberechnung, Haustür-/Kontaktlos-Logik, Vollständigkeit der vier Sprachressourcen sowie Umfang, Lizenzkennzeichnung und Berliner Plausibilität der Rückgabestellen.

## Lokal verifiziert

Stand 7. September 2026 wurde das Projekt mit Xcode 26.4 für einen **iPhone 16 Pro Simulator (iOS 18.3.1)** neu gebaut, installiert und eigenständig gestartet. Die vollständige XCTest-Suite bestand **20 von 20 Tests**. Die vier `Localizable.strings`-Kataloge enthalten jeweils **309 identische Schlüssel**. Deutsch sowie Arabisch im echten RTL-Layout wurden im laufenden Simulator visuell geprüft. Der mitgelieferte OSM-Provider lädt 177 Punkte; Tests prüfen die Aufteilung, Berlin-Koordinaten, Evidenzhinweise und Attribution.

Damit verifiziert sind Kompilierung, App-Start, Haustür-/Kontaktlos-Fluss, Status- und Validierungslogik, 8-/15-/25-Cent-Berechnung, lokaler Foto-Fallback, Sprachressourcen, RTL sowie die lizenzierte Rückgabedaten-Grenze. Nicht verifiziert sind reale Kamera-Erkennungsqualität, Muttersprachler-Lektorat, Vollständigkeit/Live-Status der OSM-Daten, Backendbetrieb zwischen mehreren Geräten oder App-Store-Freigabe.

## Konten in der Produktionsfassung

Öffentliches Stöbern sollte ohne Konto möglich bleiben. Für das Erstellen und Annehmen eines Angebots ist ein schlankes Konto sinnvoll, weil genau diese Aktionen Zuständigkeit, Adressfreigabe, Stornierung und Missbrauchsschutz brauchen. Ein öffentliches soziales Profil ist dafür nicht nötig; Anzeigename, verifizierte Kontaktmöglichkeit und interne Vertrauens-/Moderationsdaten genügen.

## Vor Produktion und App-Store-Einreichung

Der lokale Prototyp ist kein produktionsbereiter Dienst. Vor einer Veröffentlichung sind mindestens nötig:

1. **Apple-Konto und Signing:** App-ID, Distribution-Zertifikat, Provisioning und App-Store-Connect-Eintrag unter dem endgültigen Betreiberkonto.
2. **Backend und Identität:** authentifizierter Cloudflare-Dienst, serverseitige Berechtigungsprüfung, idempotente Claim-Transaktion und Audit-Log.
3. **Standort:** Einwilligungsdialog nur falls GPS ergänzt wird; datensparsame Rundung/Geofencing; klare Löschfristen. Der Prototyp fordert bewusst keine Standortberechtigung an.
4. **Kamera & Bilder:** finalen Kamera-Berechtigungstext je Sprache prüfen, Ablehnung/Elternkontrollen auf realen Geräten testen und die lokale Bildverarbeitung in Datenschutzangaben beschreiben. Falls Bilder später gespeichert oder hochgeladen würden, wäre eine neue ausdrückliche Produkt- und Datenschutzentscheidung nötig.
5. **Schätzmodell:** mit vielfältigen realen Fotos, Lichtbedingungen, Dosen, Glas/PET, verdeckten Behältern und Nicht-Pfand-Gegenständen kalibrieren; Fehlerraten messen. Die Konturheuristik ist keine produktionsreife Objekterkennung.
6. **Karten und Rückgabestellen:** den OSM-Import regelmässig und nachvollziehbar aktualisieren, Datendichte/Clustering für weitere Städte lösen und weiterhin keine Vollständigkeit oder Echtzeit-Öffnung behaupten.
7. **Moderation:** funktionierender Report-Workflow, Blockieren, Reaktionszeiten, Eskalation, Missbrauchsprävention und erreichbarer Support. Der Demo-Report wird nur bestätigt, nicht versendet.
8. **Sicherheit:** Alters-/Nutzungsregeln, Risikoanalyse für persönliche Übergaben, Notfalltext, Rate Limits und Schutz vor Standort-Scraping.
9. **Recht & Datenschutz:** Datenschutzerklärung, Nutzungsbedingungen, Impressum/Betreiberangaben, Datenverarbeitungsverzeichnis und finale App-Privacy-Angaben in App Store Connect.
10. **Qualität & Sprache:** VoiceOver, Dynamic Type, Kontrast, RTL, alle vier Sprachen, Offline-/Fehlerzustände, reale Geräte, schwaches Netz und vollständige End-to-End-Moderation mit Muttersprachler:innen prüfen.
11. **Store-Material:** lokalisierte Screenshots, Untertitel/Beschreibung, Support- und Datenschutz-URL, Inhaltsbewertung und Review-Notizen.
