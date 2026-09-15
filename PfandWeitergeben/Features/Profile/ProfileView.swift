import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: DemoOfferStore
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.de.rawValue
    @AppStorage("useLargeMapMarkers") private var useLargeMapMarkers = true
    @AppStorage("notifyClaims") private var notifyClaims = true
    @AppStorage(LocalIdentity.displayNameKey) private var displayName = ""
    @State private var showingReset = false

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackground()
                List {
                    Section("Konto") {
                        TextField("Anzeigename", text: $displayName)
                            .textContentType(.nickname)
                            .textInputAutocapitalization(.words)
                        LabeledContent("Modus", value: L10n.string("account.mode_local"))
                        Text("Kein Konto, kein Passwort: Dein Name steht nur auf deinen Angeboten und Abholungen auf diesem Gerät. Ein vierstelliger Abholcode bestätigt jede Übergabe.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Section("App-Einstellungen") {
                        Picker("Sprache", selection: $appLanguage) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.nativeName).tag(language.rawValue)
                            }
                        }
                        Toggle("Hinweis bei Annahme", isOn: $notifyClaims)
                        Toggle("Große Kartenmarkierungen", isOn: $useLargeMapMarkers)
                    }

                    Section("Sicherheit & Vertrauen") {
                        NavigationLink { SafetyCentreView() } label: { Label("Sicherheitszentrum", systemImage: "shield") }
                        NavigationLink { SupportServicesView() } label: { Label("Hilfe in Berlin", systemImage: "cross.case") }
                        NavigationLink { CommunityRulesView() } label: { Label("Gemeinschaftsregeln", systemImage: "person.2") }
                        Label("Standorte bleiben zunächst ungefähr", systemImage: "location.slash")
                    }

                    Section("Demo") {
                        Button("Demo-Daten zurücksetzen", role: .destructive) { showingReset = true }
                        LabeledContent("Datenspeicherung", value: L10n.string("storage.on_device"))
                        LabeledContent("Version", value: "1.0 (1)")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Einstellungen")
            .confirmationDialog("Demo-Daten zurücksetzen?", isPresented: $showingReset) {
                Button("Zurücksetzen", role: .destructive) { store.resetDemo() }
                Button("Abbrechen", role: .cancel) {}
            }
        }
    }
}

private struct SafetyCentreView: View {
    var body: some View {
        List {
            SafetyRow(symbol: "door.left.hand.open", title: "An der Tür bleiben", text: "Die abholende Person bleibt außerhalb der Wohnung. Lass niemanden hinein.")
            SafetyRow(symbol: "shippingbox", title: "Kontaktlos abholen", text: "Wenn beide Seiten es möchten, kann der Beutel kurz vor dem vereinbarten Zeitpunkt vor der Tür abgestellt werden.")
            SafetyRow(symbol: "person.crop.circle.badge.questionmark", title: "Privat bleiben", text: "Die genaue Adresse wird erst nach Annahme angezeigt. Teile keine zusätzlichen Kontaktdaten oder Zahlungsdaten.")
            SafetyRow(symbol: "xmark.octagon", title: "Abbrechen", text: "Wenn sich etwas falsch anfühlt, beende die Abholung und zieh das Angebot zurück.")
            SafetyRow(symbol: "exclamationmark.bubble", title: "Melden", text: "Melde unangemessene Inhalte oder verdächtiges Verhalten direkt am Angebot.")
            Section("Im Notfall") {
                Text("Bei akuter gesundheitlicher Gefahr oder wenn jemand nicht ansprechbar ist, ruf 112. Bei unmittelbarer Bedrohung ruf 110. Die App ist kein Notfalldienst.")
            }
        }
        .navigationTitle("Sicherheitszentrum")
    }
}

private struct SupportServicesView: View {
    var body: some View {
        List {
            Section {
                Text("Direkte, freiwillige Kontakte für dich oder jemanden in deiner Nähe. Die App leitet keine Daten weiter und ruft niemanden automatisch an.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Akute Hilfe") {
                Link(destination: URL(string: "tel:112")!) {
                    SupportLinkRow(symbol: "cross.circle.fill", title: "Rettungsdienst · 112", detail: "Bei akuter gesundheitlicher Gefahr oder wenn jemand nicht ansprechbar ist")
                }
                Link(destination: URL(string: "tel:110")!) {
                    SupportLinkRow(symbol: "shield.fill", title: "Polizei · 110", detail: "Bei unmittelbarer Bedrohung")
                }
            }

            Section("Wohnungsnotfallhilfe") {
                Link(destination: URL(string: "tel:+4930690333690")!) {
                    SupportLinkRow(symbol: "bus.fill", title: "Kältebus · 030 690 333 690", detail: "Saisonaler Abenddienst der Berliner Stadtmission; nur anrufen, wenn die Person Hilfe annehmen möchte")
                }
                Link(destination: URL(string: "tel:+493034397140")!) {
                    SupportLinkRow(symbol: "phone.fill", title: "Kältehilfetelefon · 030 343 971 40", detail: "Informationen zu verfügbaren Schlafplätzen während der Kältehilfesaison")
                }
                Link(destination: URL(string: "https://www.kaeltehilfe-berlin.de/wegweiser-shelter-map")!) {
                    SupportLinkRow(symbol: "map.fill", title: "Kältehilfe-Wegweiser öffnen", detail: "Aktuelle Notübernachtungen, Tagesangebote und Beratung in Berlin")
                }
                Link(destination: URL(string: "https://www.berlin.de/sen/soziales/besondere-lebenssituationen/wohnungslose/praevention/")!) {
                    SupportLinkRow(symbol: "building.2.fill", title: "Soziale Wohnhilfe Berlin", detail: "Bezirkliche Hilfe bei Wohnungsverlust, Mietschulden oder fehlender Unterkunft")
                }
            }

            Section {
                Text("Zeiten und Kapazitäten können sich ändern. Prüfe den aktuellen Wegweiser oder die verlinkte Stelle.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Hilfe in Berlin")
    }
}

private struct SupportLinkRow: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(AppTheme.green)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(LocalizedStringKey(title)).font(.headline)
                Text(LocalizedStringKey(detail)).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
}

private struct SafetyRow: View {
    let symbol: String, title: String, text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol).foregroundStyle(AppTheme.green).frame(width: 28)
            VStack(alignment: .leading, spacing: 3) { Text(LocalizedStringKey(title)).font(.headline); Text(LocalizedStringKey(text)).font(.subheadline).foregroundStyle(.secondary) }
        }
        .padding(.vertical, 5)
    }
}

private struct CommunityRulesView: View {
    var body: some View {
        List {
            Label("Nur Pfandbehälter anbieten, die tatsächlich bereitstehen.", systemImage: "checkmark.circle")
            Label("Zeitfenster und Beutelgröße ehrlich beschreiben.", systemImage: "checkmark.circle")
            Label("Respektvoll kommunizieren und vereinbarte Zeiten einhalten.", systemImage: "checkmark.circle")
            Label("Kein Verkauf: Die abholende Person behält ausschließlich den Pfandwert.", systemImage: "eurosign.circle")
        }
        .navigationTitle("Gemeinschaftsregeln")
    }
}
