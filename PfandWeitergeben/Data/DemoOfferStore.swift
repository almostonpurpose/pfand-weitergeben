import Foundation
import Combine

@MainActor
final class DemoOfferStore: ObservableObject, OfferProviding {
    @Published private(set) var offers: [Offer] {
        didSet { persistence?.save(offers) }
    }
    private let persistence: OfferPersistence?

    /// In-memory store seeded with `offers`; used by previews and tests.
    init(offers: [Offer] = DemoData.offers) {
        self.offers = offers
        self.persistence = nil
    }

    /// Store backed by a file on this device. Stored offers are merged with the demo seed so
    /// untouched demo entries keep fresh pickup windows.
    init(persistence: OfferPersistence) {
        self.persistence = persistence
        if let stored = persistence.load() {
            self.offers = OfferPersistence.merge(stored: stored, seed: DemoData.offers)
        } else {
            self.offers = DemoData.offers
        }
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
            distanceMetres: 180, owner: LocalIdentity.participant, collector: nil,
            status: .open, createdAt: Date()
        )
        offers.insert(offer, at: 0)
        return offer
    }

    @discardableResult
    func claim(id: UUID) throws -> String {
        let code = HandoverCode.generate()
        try transition(id: id, to: .claimed) {
            $0.collector = LocalIdentity.participant
            $0.handoverCode = code
        }
        return code
    }

    func markCollected(id: UUID, handoverCode: String) throws {
        guard let offer = offers.first(where: { $0.id == id }) else { throw OfferStoreError.notFound }
        guard offer.status.canTransition(to: .collected) else {
            throw OfferStoreError.transition(.invalidTransition(from: offer.status, to: .collected))
        }
        guard HandoverCode.matches(handoverCode, offer.handoverCode) else {
            throw OfferStoreError.wrongHandoverCode
        }
        try transition(id: id, to: .collected)
    }

    func cancel(id: UUID) throws {
        try transition(id: id, to: .cancelled)
    }

    func resetDemo() {
        persistence?.clear()
        offers = DemoData.offers
    }

    private func transition(id: UUID, to next: OfferStatus, mutate: (inout Offer) -> Void = { _ in }) throws {
        guard let index = offers.firstIndex(where: { $0.id == id }) else { throw OfferStoreError.notFound }
        guard offers[index].status.canTransition(to: next) else {
            throw OfferStoreError.transition(.invalidTransition(from: offers[index].status, to: next))
        }
        mutate(&offers[index])
        offers[index].status = next
    }
}
