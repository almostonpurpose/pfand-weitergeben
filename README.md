# Pfand weitergeben

Eine native iPhone-App, über die Nachbar:innen Pfandflaschen unkompliziert weitergeben: Eine Person stellt ein Angebot ein, eine andere nimmt es an, holt die Behälter ab und **behält den vollständigen Pfandbetrag**.

Der aktuelle Stand ist ein polierter, vollständig lokaler Prototyp. Er startet ohne Konto, Server oder Zugangsdaten mit realistischen Demo-Angeboten.

## Öffnen und starten

1. `PfandWeitergeben.xcodeproj` in Xcode öffnen.
2. Das Scheme **PfandWeitergeben** und einen iPhone-Simulator mit iOS 17 oder neuer wählen.
3. Run (`⌘R`) drücken.

Für ein eigenes Gerät unter **Signing & Capabilities** das persönliche Apple-Developer-Team auswählen. Die Bundle-ID kann bei Bedarf geändert werden.

## Enthalten

- Kartenbasierte Angebotssuche mit zugänglicher Listenalternative
- Zwei optionale, klar unterscheidbare Kartenebenen für Supermarkt-Pfandrückgaben und öffentliche Glascontainer, jeweils auch als gefilterte Liste und mit Legende
- Angebot erstellen: Flaschenzahl, Beutelgröße, Zeitfenster, Hinweise und öffentlicher Treffpunkt
- Detailansicht mit gut sichtbarem Pfand-Hinweis und Annahme
- Aktivitätsansicht für `verfügbar → vereinbart → abgeholt` sowie Stornierung
- Sicherheitszentrum, Angebotsmeldung, Gemeinschaftsregeln und Einstellungen
- Vollständige App-Sprache in Deutsch, Englisch, Arabisch und Türkisch; Deutsch ist Standard, Arabisch nutzt RTL-Layout
- In-App-Sprachwahl unter **Profil → Einstellungen → Sprache**
- Schnelle lokale Foto-Schätzung per Kamera oder Fotomediathek mit bearbeitbarer Anzahl und bearbeitbarem Pfandwert
- Ungefähre Standortdarstellung vor Annahme; keine Wohnadresse im Datenmodell
- Lokaler Demo-Speicher hinter dem `OfferProviding`-Protokoll
- Lokale Berliner Beispiel-Rückgabestellen hinter dem austauschbaren `ReturnPointProviding`-Protokoll
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

Die beiden optionalen Kartenebenen enthalten im Offline-Demo jeweils drei ausdrücklich als **Beispieldaten** bezeichnete Berliner Punkte. Sie dienen nur dazu, Kartenmarker, Legende, Filter und Listenansicht unmittelbar ausprobieren zu können.

- Die Supermarkt-Punkte sind keine vollständige Händlerliste und bestätigen nicht, dass ein Markt alle Behälterarten annimmt.
- Die Glascontainer-Punkte sind ebenfalls Demo-Einträge, keine amtlich geprüften Standorte.
- Es werden weder Verfügbarkeit noch Öffnungs- oder Leerungsstatus in Echtzeit behauptet.
- `ReturnPointProviding` trennt die Oberfläche vom Ursprung der Daten. Eine Produktionsimplementierung muss eine nachweislich lizenzierte öffentliche/Open-Data-Quelle verwenden, Attribution, Lizenz, Aktualisierungszeit und Qualitätsgrenzen erhalten und dokumentieren.
- Supermarktstandorte dürfen nicht als vollständig bezeichnet werden; Öffnungszeiten dürfen nur angezeigt werden, wenn Quelle und Aktualität dafür belastbar sind.

Das Demo fordert weiterhin keinen Gerätestandort an. Die sichtbaren Rückgabestellen sind öffentliche Beispiel-POIs; sie ändern nichts an der ungefähren Darstellung persönlicher Übergabeorte.

## Foto-Schätzung und Datenschutz

Die Angebotserstellung kann ein Foto aufnehmen oder über Apples systemeigenen Photo Picker auswählen. Eine lokale Vision-Konturanalyse liefert einen bewusst groben Startwert für Anzahl und Pfandbetrag. Beides bleibt editierbar und muss manuell bestätigt werden.

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

Getestet werden Validierung, erlaubte/verbotene Statusübergänge, Foto-Fallback, die Vollständigkeit der vier Sprachressourcen sowie Umfang, Kennzeichnung und Berliner Plausibilität der Demo-Rückgabestellen.

## Lokal verifiziert

Stand 31. August 2026 wurde das Projekt mit Xcode 26.4 für einen **iPhone 16 Pro Simulator (iOS 18.3.1)** neu gebaut, installiert und eigenständig gestartet. Die vollständige XCTest-Suite bestand **16 von 16 Tests**. Die vier `Localizable.strings`-Kataloge enthalten jeweils **177 identische Schlüssel**; Platzhalter-Arity und Property-List-Syntax wurden ebenfalls geprüft. Der gebaute App-Bundle weist Deutsch als Entwicklungsregion und `de`, `en`, `ar`, `tr` als unterstützte Sprachen aus.

Damit verifiziert sind Kompilierung, App-Start, Status- und Validierungslogik, lokaler Foto-Fallback, Sprachressourcen sowie die Demo-Providergrenze und Berliner Plausibilität der Rückgabestellen. Nicht verifiziert sind reale Kamera-Erkennungsqualität, Muttersprachler-Lektorat, reale Rückgabestellen-/Öffnungsdaten, Backendbetrieb oder App-Store-Freigabe.

## Vor Produktion und App-Store-Einreichung

Der lokale Prototyp ist kein produktionsbereiter Dienst. Vor einer Veröffentlichung sind mindestens nötig:

1. **Apple-Konto und Signing:** App-ID, Distribution-Zertifikat, Provisioning und App-Store-Connect-Eintrag unter dem endgültigen Betreiberkonto.
2. **Backend und Identität:** authentifizierter Cloudflare-Dienst, serverseitige Berechtigungsprüfung, idempotente Claim-Transaktion und Audit-Log.
3. **Standort:** Einwilligungsdialog nur falls GPS ergänzt wird; datensparsame Rundung/Geofencing; klare Löschfristen. Der Prototyp fordert bewusst keine Standortberechtigung an.
4. **Kamera & Bilder:** finalen Kamera-Berechtigungstext je Sprache prüfen, Ablehnung/Elternkontrollen auf realen Geräten testen und die lokale Bildverarbeitung in Datenschutzangaben beschreiben. Falls Bilder später gespeichert oder hochgeladen würden, wäre eine neue ausdrückliche Produkt- und Datenschutzentscheidung nötig.
5. **Schätzmodell:** mit vielfältigen realen Fotos, Lichtbedingungen, Dosen, Glas/PET, verdeckten Behältern und Nicht-Pfand-Gegenständen kalibrieren; Fehlerraten messen. Die Konturheuristik ist keine produktionsreife Objekterkennung.
6. **Karten und Rückgabestellen:** MapKit-Nutzung auf reale Region und Verfügbarkeit testen. Für Treffpunkte eine kuratierte/moderierte Quelle vorsehen. Für Supermarkt-Rücknahmen und Glascontainer eine korrekt lizenzierte öffentliche/Open-Data-Quelle auswählen, Nutzungsbedingungen und Attribution prüfen, Aktualisierungsrhythmus sowie Datenalter offenlegen und keine Vollständigkeit oder Echtzeit-Öffnung behaupten.
7. **Moderation:** funktionierender Report-Workflow, Blockieren, Reaktionszeiten, Eskalation, Missbrauchsprävention und erreichbarer Support. Der Demo-Report wird nur bestätigt, nicht versendet.
8. **Sicherheit:** Alters-/Nutzungsregeln, Risikoanalyse für persönliche Übergaben, Notfalltext, Rate Limits und Schutz vor Standort-Scraping.
9. **Recht & Datenschutz:** Datenschutzerklärung, Nutzungsbedingungen, Impressum/Betreiberangaben, Datenverarbeitungsverzeichnis und finale App-Privacy-Angaben in App Store Connect.
10. **Qualität & Sprache:** VoiceOver, Dynamic Type, Kontrast, RTL, alle vier Sprachen, Offline-/Fehlerzustände, reale Geräte, schwaches Netz und vollständige End-to-End-Moderation mit Muttersprachler:innen prüfen.
11. **Store-Material:** lokalisierte Screenshots, Untertitel/Beschreibung, Support- und Datenschutz-URL, Inhaltsbewertung und Review-Notizen.
