import SwiftUI

struct CreateOfferView: View {
    @ObservedObject var store: DemoOfferStore
    let onCreated: () -> Void
    @State private var draft = OfferDraft()
    @State private var photoEstimatedCount = 0
    @State private var showingConfirmation = false
    @State private var errorMessage: String?
    @State private var showingPrivacyInfo = false

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        CareHeading(title: "Angebot erstellen", note: "Angaben zur Abholung")

                        FormSection(number: "01", title: "Foto-Schätzung") {
                            PhotoEstimateView(roughCount: $photoEstimatedCount)
                        }

                        FormSection(number: "02", title: "Behälter und Pfandwert") {
                            if photoEstimatedCount > 0 {
                                Label(L10n.string("deposit.photo_count", photoEstimatedCount), systemImage: "camera.viewfinder")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            ForEach(DepositType.allCases) { type in
                                DepositCountRow(type: type, count: depositBinding(for: type))
                                if type != DepositType.allCases.last { Divider() }
                            }

                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Gesamt").font(.headline)
                                    Text(L10n.string("offer.bottle_count_plain", draft.bottleCount))
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(L10n.currency(draft.estimatedDeposit))
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(AppTheme.green)
                            }

                            Picker("Beutelgröße", selection: $draft.bagSize) {
                                ForEach(BagSize.allCases) { size in
                                    Label(size.title, systemImage: size.symbol).tag(size)
                                }
                            }
                            .pickerStyle(.menu)

                            Text("Mehrwegpfand beträgt üblicherweise 8 oder 15 Cent; Einwegpfand 25 Cent. Prüfe im Zweifel das Etikett.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        FormSection(number: "03", title: "Abholzeit") {
                            QuarterHourRangePicker(start: $draft.pickupStart, end: $draft.pickupEnd)
                        }

                        FormSection(number: "04", title: "Abholort und Übergabe") {
                            Picker("Übergabeart", selection: $draft.handoverMethod) {
                                ForEach(HandoverMethod.allCases) { method in
                                    Label(method.title, systemImage: method.symbol).tag(method)
                                }
                            }
                            .pickerStyle(.inline)

                            Text(draft.handoverMethod.note)
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            if draft.handoverMethod.requiresPrivateAddress {
                                TextField("Straße, Hausnummer, Postleitzahl", text: $draft.privateAddress)
                                    .textContentType(.fullStreetAddress)
                                    .textInputAutocapitalization(.words)

                                Picker("Ungefähre Gegend auf der Karte", selection: $draft.meetingPoint) {
                                    Text("Bitte wählen").tag(Optional<MeetingPoint>.none)
                                    ForEach(DemoData.meetingPoints, id: \.self) { point in
                                        Text(point.neighbourhood).tag(Optional(point))
                                    }
                                }
                                .pickerStyle(.menu)
                            } else {
                                Picker("Vereinbarter Ort", selection: $draft.meetingPoint) {
                                    Text("Bitte wählen").tag(Optional<MeetingPoint>.none)
                                    ForEach(DemoData.meetingPoints, id: \.self) { point in
                                        Text("\(point.name), \(point.neighbourhood)").tag(Optional(point))
                                    }
                                }
                                .pickerStyle(.menu)
                            }

                            Button { showingPrivacyInfo = true } label: {
                                Label("Wer sieht die genaue Adresse?", systemImage: "lock.shield")
                            }
                            .font(.subheadline)
                        }

                        FormSection(number: "05", title: "Zusätzliche Hinweise") {
                            TextField("z. B. Beutel steht links neben der Tür", text: $draft.instructions, axis: .vertical)
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
                            Label("Angebot erstellen", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(PrimaryActionButtonStyle())
                        .disabled(!draft.isValid)
                        .opacity(draft.isValid ? 1 : 0.45)

                        Text("Vor der Annahme ist nur die ungefähre Gegend sichtbar. Die genaue Adresse oder der vereinbarte Ort wird erst danach angezeigt.")
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
            .alert("Angebot erstellt", isPresented: $showingConfirmation) {
                Button("Zur Aktivität") { onCreated() }
                Button("Weiteres Angebot erstellen", role: .cancel) {}
            } message: {
                Text("Das Angebot ist jetzt in der Demo sichtbar.")
            }
            .alert("Adressschutz", isPresented: $showingPrivacyInfo) {
                Button("Verstanden", role: .cancel) {}
            } message: {
                Text("Vor der Annahme sehen andere nur die ungefähre Gegend. Die genaue Abholadresse wird ausschließlich der Person angezeigt, die das Angebot angenommen hat.")
            }
            .alert("Fehler", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func depositBinding(for type: DepositType) -> Binding<Int> {
        Binding(
            get: { draft.depositBreakdown.count(for: type) },
            set: { draft.depositBreakdown.setCount($0, for: type) }
        )
    }

    private func createOffer() {
        do {
            _ = try store.create(from: draft)
            draft = OfferDraft()
            photoEstimatedCount = 0
            showingConfirmation = true
        } catch { errorMessage = error.localizedDescription }
    }
}

private struct DepositCountRow: View {
    let type: DepositType
    @Binding var count: Int

    var body: some View {
        Stepper(value: $count, in: 0...200) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.title).font(.headline)
                    Text(type.note).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(count)")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.green)
                    .monospacedDigit()
            }
        }
        .accessibilityValue(L10n.string("deposit.row_accessibility", count, type.cents))
    }
}

private struct QuarterHourRangePicker: View {
    @Binding var start: Date
    @Binding var end: Date
    private let calendar = Calendar.current
    private let startSlots = Array(stride(from: 0, through: 1_410, by: 15))
    private let endSlots = Array(stride(from: 15, through: 1_425, by: 15))

    var body: some View {
        DatePicker("Tag", selection: dayBinding, in: calendar.startOfDay(for: Date())..., displayedComponents: .date)

        Picker("Beginn", selection: startMinuteBinding) {
            ForEach(startSlots, id: \.self) { minute in
                Text(timeLabel(minute)).tag(minute)
            }
        }
        .pickerStyle(.menu)

        Picker("Ende", selection: endMinuteBinding) {
            ForEach(endSlots.filter { $0 > minutes(in: start) }, id: \.self) { minute in
                Text(timeLabel(minute)).tag(minute)
            }
        }
        .pickerStyle(.menu)

        Text("Zeiten sind in 15-Minuten-Schritten auswählbar.")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    private var dayBinding: Binding<Date> {
        Binding(
            get: { start },
            set: { day in
                let startMinute = minutes(in: start)
                let endMinute = max(minutes(in: end), startMinute + 15)
                start = date(on: day, minute: startMinute)
                end = date(on: day, minute: min(endMinute, 1_425))
            }
        )
    }

    private var startMinuteBinding: Binding<Int> {
        Binding(
            get: { min(minutes(in: start), 1_410) },
            set: { minute in
                let day = start
                start = date(on: day, minute: minute)
                if end <= start {
                    end = date(on: day, minute: min(minute + 60, 1_425))
                }
            }
        )
    }

    private var endMinuteBinding: Binding<Int> {
        Binding(
            get: { max(minutes(in: end), minutes(in: start) + 15) },
            set: { end = date(on: start, minute: $0) }
        )
    }

    private func minutes(in date: Date) -> Int {
        calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
    }

    private func date(on day: Date, minute: Int) -> Date {
        calendar.date(bySettingHour: minute / 60, minute: minute % 60, second: 0, of: day) ?? day
    }

    private func timeLabel(_ minute: Int) -> String {
        date(on: Date(), minute: minute).formatted(.dateTime.hour().minute().locale(L10n.locale))
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
