import Foundation
import Combine

@MainActor
final class DemoOfferStore: ObservableObject, OfferProviding {
    @Published private(set) var offers: [Offer]

    init(offers: [Offer] = DemoData.offers) {
        self.offers = offers
    }

    @discardableResult
    func create(from draft: OfferDraft) throws -> Offer {
        let issues = draft.validationIssues()
        guard issues.isEmpty, let meetingPoint = draft.meetingPoint else {
            throw OfferStoreError.validation(issues)
        }
        let offer = Offer(
            id: UUID(), depositBreakdown: draft.depositBreakdown, bagSize: draft.bagSize,
            pickupStart: draft.pickupStart, pickupEnd: draft.pickupEnd,
            instructions: draft.instructions, meetingPoint: meetingPoint,
            handoverMethod: draft.handoverMethod,
            privateAddress: draft.handoverMethod.requiresPrivateAddress ? draft.privateAddress.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            distanceMetres: 180, ownerName: "Du", collectorName: nil,
            status: .open, createdAt: Date()
        )
        offers.insert(offer, at: 0)
        return offer
    }

    func claim(id: UUID, collectorName: String = "Du") throws {
        try transition(id: id, to: .claimed) { $0.collectorName = collectorName }
    }

    func markCollected(id: UUID) throws {
        try transition(id: id, to: .collected)
    }

    func cancel(id: UUID) throws {
        try transition(id: id, to: .cancelled)
    }

    func resetDemo() { offers = DemoData.offers }

    private func transition(id: UUID, to next: OfferStatus, mutate: (inout Offer) -> Void = { _ in }) throws {
        guard let index = offers.firstIndex(where: { $0.id == id }) else { throw OfferStoreError.notFound }
        guard offers[index].status.canTransition(to: next) else {
            throw OfferStoreError.transition(.invalidTransition(from: offers[index].status, to: next))
        }
        mutate(&offers[index])
        offers[index].status = next
    }
}
