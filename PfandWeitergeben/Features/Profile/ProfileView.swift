import SwiftUI

struct ProfileView: View {
    @ObservedObject var store: DemoOfferStore
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.de.rawValue
    @AppStorage("useLargeMapMarkers") private var useLargeMapMarkers = true
    @AppStorage("notifyClaims") private var notifyClaims = true
    @State private var showingReset = false

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackground()
                List {
                    Section {
                        HStack(spacing: 15) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 50)).foregroundStyle(AppTheme.sage)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Demo-Profil").font(.headline)
                                Text("Berlin · lokal auf diesem Gerät").font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }

                    Section("Einstellungen") {
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
                        NavigationLink { CommunityRulesView() } label: { Label("Gemeinschaftsregeln", systemImage: "person.2") }
                        Label("Standorte bleiben zunächst ungefähr", systemImage: "location.slash")
                    }

                    Section("Demo") {
                        Button("Demo-Daten zurücksetzen", role: .destructive) { showingReset = true }
                        LabeledContent("Datenspeicherung", value: "Nur im Arbeitsspeicher")
                        LabeledContent("Version", value: "1.0 (1)")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Profil")
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
            SafetyRow(symbol: "building.2", title: "Öffentlich treffen", text: "Wähle einen belebten, gut beleuchteten Ort – nie eine Wohnung.")
            SafetyRow(symbol: "person.crop.circle.badge.questionmark", title: "Privat bleiben", text: "Teile keine Telefonnummer, genaue Adresse oder Zahlungsdaten.")
            SafetyRow(symbol: "xmark.octagon", title: "Abbrechen ist in Ordnung", text: "Wenn sich etwas falsch anfühlt, geh nicht hin oder beende die Übergabe.")
            SafetyRow(symbol: "exclamationmark.bubble", title: "Melden", text: "Melde unangemessene Inhalte oder verdächtiges Verhalten direkt am Angebot.")
            Section("Im Notfall") {
                Text("Bei unmittelbarer Gefahr ruf 110. Die App ist kein Notfalldienst.")
            }
        }
        .navigationTitle("Sicherheitszentrum")
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
