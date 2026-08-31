import SwiftUI

struct CreateOfferView: View {
    @ObservedObject var store: DemoOfferStore
    let onCreated: () -> Void
    @State private var draft = OfferDraft()
    @State private var showingConfirmation = false
    @State private var errorMessage: String?
    @State private var showingPrivacyInfo = false

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        CareHeading(title: "Pfand weitergeben", note: "du machst Platz — jemand anderes behält das Pfand")

                        FormSection(number: "01", title: "Schnell per Foto schätzen") {
                            PhotoEstimateView(bottleCount: $draft.bottleCount, estimatedDeposit: $draft.estimatedDeposit)
                        }

                        FormSection(number: "02", title: "Wie viel ist es?") {
                            Stepper(value: $draft.bottleCount, in: 1...200) {
                                HStack {
                                    Text("Geschätzte Anzahl")
                                    Spacer()
                                    Text("\(draft.bottleCount)").font(.title3.weight(.semibold)).foregroundStyle(AppTheme.green)
                                }
                            }
                            Picker("Größe", selection: $draft.bagSize) {
                                ForEach(BagSize.allCases) { size in
                                    Label(size.title, systemImage: size.symbol).tag(size)
                                }
                            }
                            .pickerStyle(.menu)
                            HStack {
                                Text("Geschätztes Pfand")
                                Spacer()
                                TextField("Betrag", value: $draft.estimatedDeposit, format: .number.precision(.fractionLength(2)))
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                    .frame(maxWidth: 90)
                                Text("€")
                                    .font(.headline)
                            }
                            .foregroundStyle(AppTheme.green)
                        }

                        FormSection(number: "03", title: "Wann passt es?") {
                            DatePicker("Von", selection: $draft.pickupStart, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            DatePicker("Bis", selection: $draft.pickupEnd, in: draft.pickupStart..., displayedComponents: [.date, .hourAndMinute])
                        }

                        FormSection(number: "04", title: "Wo trefft ihr euch?") {
                            Picker("Öffentlicher Treffpunkt", selection: $draft.meetingPoint) {
                                Text("Bitte wählen").tag(Optional<MeetingPoint>.none)
                                ForEach(DemoData.meetingPoints, id: \.self) { point in
                                    Text("\(point.name), \(point.neighbourhood)").tag(Optional(point))
                                }
                            }
                            .pickerStyle(.menu)
                            Button { showingPrivacyInfo = true } label: {
                                Label("Warum keine Wohnadresse?", systemImage: "hand.raised")
                            }
                            .font(.subheadline)
                        }

                        FormSection(number: "05", title: "Hinweise zur Übergabe") {
                            TextField("z. B. zwei blaue Taschen, bitte kurz melden", text: $draft.instructions, axis: .vertical)
                                .lineLimit(3...6)
                            Text("\(draft.instructions.count)/280")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(draft.instructions.count > 280 ? .red : .secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }

                        if !draft.validationIssues().isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(draft.validationIssues(), id: \.message) { issue in
                                    Label(issue.message, systemImage: "exclamationmark.circle")
                                }
                            }
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .accessibilityLabel(draft.validationIssues().map(\.message).joined(separator: " "))
                        }

                        Button { createOffer() } label: {
                            Label("Angebot veröffentlichen", systemImage: "leaf.fill")
                        }
                        .buttonStyle(PrimaryActionButtonStyle())
                        .disabled(!draft.isValid)
                        .opacity(draft.isValid ? 1 : 0.45)

                        Text("Dein Treffpunkt wird bis zur Annahme nur ungefähr angezeigt. Diese Demo speichert nichts außerhalb des Geräts.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Neues Angebot")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Angebot ist sichtbar", isPresented: $showingConfirmation) {
                Button("Zur Aktivität") { onCreated() }
                Button("Noch eins erstellen", role: .cancel) {}
            } message: {
                Text("Menschen in deiner Nähe können es jetzt annehmen und behalten den gesamten Pfandbetrag.")
            }
            .alert("Deine Privatsphäre", isPresented: $showingPrivacyInfo) {
                Button("Verstanden", role: .cancel) {}
            } message: {
                Text("Die App fragt nie nach deiner Wohnung. Wähle einen öffentlichen Ort. Vor der Annahme sehen andere nur die ungefähre Umgebung.")
            }
            .alert("Das hat nicht geklappt", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func createOffer() {
        do {
            _ = try store.create(from: draft)
            draft = OfferDraft()
            showingConfirmation = true
        } catch { errorMessage = error.localizedDescription }
    }
}

private struct FormSection<Content: View>: View {
    let number: String
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(number).font(.caption.monospaced()).foregroundStyle(AppTheme.sage)
                Text(LocalizedStringKey(title)).font(.title3.weight(.medium)).foregroundStyle(AppTheme.ink)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

struct CreateOfferView_Previews: PreviewProvider {
    static var previews: some View {
        CreateOfferView(store: DemoOfferStore(), onCreated: {})
    }
}
