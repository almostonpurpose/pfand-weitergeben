import SwiftUI

struct OfferDetailView: View {
    @ObservedObject var store: DemoOfferStore
    let offerID: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var showingSafety = false
    @State private var showingReport = false
    @State private var errorMessage: String?

    private var offer: Offer? { store.offers.first { $0.id == offerID } }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackground()
                if let offer {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 22) {
                            CareHeading(title: L10n.string("detail.waiting", offer.bottleCount), note: L10n.string("detail.pickup"))
                            OfferCard(offer: offer)

                            DetailSection(title: "Abholort", symbol: offer.handoverMethod.symbol) {
                                Text(offer.handoverMethod.title)
                                    .font(.headline)
                                if offer.status == .open {
                                    Text(L10n.string("detail.home_location_privacy", offer.meetingPoint.neighbourhood))
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text(offer.confirmedPickupLocation)
                                        .font(.headline)
                                    Text(offer.handoverMethod.note)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            DetailSection(title: L10n.string("detail.instructions_from", displayActorName(offer.ownerName)), symbol: "text.bubble") {
                                Text(offer.displayInstructions.isEmpty ? L10n.string("detail.no_instructions") : offer.displayInstructions)
                            }

                            SafetyNote()

                            if offer.status == .open {
                                Button { claim() } label: {
                                    Label("Annehmen und Pfand behalten", systemImage: "hand.raised.fill")
                                }
                                .buttonStyle(PrimaryActionButtonStyle())
                                Text("Mit der Annahme vereinbarst du die Abholung. Der gesamte Pfandbetrag gehört dir.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            } else {
                                StatusPill(status: offer.status)
                            }

                            HStack {
                                Button("Sicherheitstipps") { showingSafety = true }
                                Spacer()
                                Button("Angebot melden", role: .destructive) { showingReport = true }
                            }
                            .font(.subheadline)
                        }
                        .padding(18)
                    }
                } else {
                    ContentUnavailableView("Angebot nicht gefunden", systemImage: "questionmark.folder")
                }
            }
            .navigationTitle("Angebot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Fertig") { dismiss() } } }
            .alert("Sicher abholen", isPresented: $showingSafety) {
                Button("Verstanden", role: .cancel) {}
            } message: {
                Text("Bei Abholung an einer Wohnung bleibt die abholende Person draußen. Nutze bei Bedarf die kontaktlose Ablage vor der Tür und brich die Abholung ab, wenn sich etwas falsch anfühlt.")
            }
            .confirmationDialog("Warum möchtest du das Angebot melden?", isPresented: $showingReport, titleVisibility: .visible) {
                Button("Unangemessener Inhalt", role: .destructive) { reportAcknowledged() }
                Button("Verdächtiges Verhalten", role: .destructive) { reportAcknowledged() }
                Button("Falsche Angaben", role: .destructive) { reportAcknowledged() }
                Button("Abbrechen", role: .cancel) {}
            }
            .alert("Hinweis", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func claim() {
        do {
            try store.claim(id: offerID, collectorName: "Du")
            errorMessage = L10n.string("claim.success")
        } catch { errorMessage = error.localizedDescription }
    }

    private func reportAcknowledged() {
        errorMessage = L10n.string("report.acknowledged")
    }
}

private struct DetailSection<Content: View>: View {
    let title: String
    let symbol: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(LocalizedStringKey(title), systemImage: symbol).font(.headline).foregroundStyle(AppTheme.ink)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private func displayActorName(_ name: String) -> String {
    name == "Du" ? L10n.string("actor.you") : name
}

private struct SafetyNote: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "shield.checkered").font(.title3).foregroundStyle(AppTheme.green)
            VStack(alignment: .leading, spacing: 3) {
                Text("Abholung an der Adresse").font(.headline)
                Text("Die genaue Adresse wird erst nach Annahme angezeigt. Die abholende Person bleibt außerhalb der Wohnung; eine Ablage vor der Tür ist möglich.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(AppTheme.sageTint, in: RoundedRectangle(cornerRadius: 16))
    }
}
