import SwiftUI

struct ActivityView: View {
    @ObservedObject var store: DemoOfferStore
    @State private var errorMessage: String?

    private var active: [Offer] { store.offers.filter { $0.status == .claimed } }
    private var mine: [Offer] { store.offers.filter { $0.ownerName == "Du" } }
    private var history: [Offer] { store.offers.filter { [.collected, .cancelled].contains($0.status) } }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        CareHeading(title: "Abholungen", note: "aktive und abgeschlossene Vorgänge")

                        if active.isEmpty && mine.isEmpty {
                            ContentUnavailableView("Keine aktiven Abholungen", systemImage: "shippingbox", description: Text("Nimm ein Angebot an oder erstelle ein Angebot."))
                                .frame(minHeight: 280)
                        }

                        if !active.isEmpty {
                            ActivitySection(title: "Deine Abholungen") {
                                ForEach(active) { offer in ActiveOfferCard(offer: offer, store: store, errorMessage: $errorMessage) }
                            }
                        }

                        if !mine.isEmpty {
                            ActivitySection(title: "Von dir eingestellt") {
                                ForEach(mine) { offer in ActiveOfferCard(offer: offer, store: store, errorMessage: $errorMessage) }
                            }
                        }

                        if !history.isEmpty {
                            ActivitySection(title: "Erledigt") {
                                ForEach(history) { offer in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(L10n.string("offer.bottle_count_plain", offer.bottleCount)).font(.headline)
                                            Text(offer.meetingPoint.neighbourhood).font(.subheadline).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        StatusPill(status: offer.status)
                                    }
                                    .cardStyle()
                                }
                            }
                        }
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Aktivität")
            .alert("Hinweis", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: { Text(errorMessage ?? "") }
        }
    }
}

private struct ActivitySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey(title)).font(.title3.weight(.medium)).foregroundStyle(AppTheme.ink)
            content
        }
    }
}

private struct ActiveOfferCard: View {
    let offer: Offer
    @ObservedObject var store: DemoOfferStore
    @Binding var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.string("offer.bottle_count_plain", offer.bottleCount)).font(.headline)
                    Text(offer.pickupTimeText).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                StatusPill(status: offer.status)
            }
            Divider()
            Label(locationText, systemImage: offer.handoverMethod.symbol)
                .font(.subheadline)
            if offer.collectorName == "Du" {
                Text(L10n.string("activity.you_collect", L10n.currency(offer.estimatedDeposit)))
                    .font(.subheadline.weight(.semibold)).foregroundStyle(AppTheme.green)
            } else if offer.ownerName == "Du" {
                Text(offer.collectorName.map { L10n.string("activity.collector_collects", displayActorName($0)) } ?? L10n.string("activity.not_claimed"))
                    .font(.subheadline).foregroundStyle(AppTheme.green)
            }

            if offer.status == .claimed {
                Button("Als abgeholt markieren") {
                    do { try store.markCollected(id: offer.id) }
                    catch { errorMessage = error.localizedDescription }
                }
                .buttonStyle(PrimaryActionButtonStyle())
                Button("Abholung absagen", role: .destructive) {
                    do { try store.cancel(id: offer.id) }
                    catch { errorMessage = error.localizedDescription }
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
            } else if offer.status == .open && offer.ownerName == "Du" {
                Button("Angebot zurückziehen", role: .destructive) {
                    do { try store.cancel(id: offer.id) }
                    catch { errorMessage = error.localizedDescription }
                }
                .font(.subheadline)
            }
        }
        .cardStyle()
    }

    private var locationText: String {
        if offer.status == .claimed || offer.ownerName == "Du" {
            return L10n.string("activity.confirmed_location", offer.confirmedPickupLocation)
        }
        return L10n.string("activity.approximate_location", offer.meetingPoint.neighbourhood)
    }
}

private func displayActorName(_ name: String) -> String {
    name == "Du" ? L10n.string("actor.you") : name
}
