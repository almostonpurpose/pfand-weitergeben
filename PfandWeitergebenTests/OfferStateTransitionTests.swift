import XCTest
@testable import PfandWeitergeben

@MainActor
final class OfferStateTransitionTests: XCTestCase {
    private func makeOpenOffer() -> Offer {
        Offer(id: UUID(), bottleCount: 10, bagSize: .medium,
              pickupStart: Date().addingTimeInterval(3_600), pickupEnd: Date().addingTimeInterval(7_200),
              instructions: "", meetingPoint: DemoData.meetingPoints[0], distanceMetres: 100,
              ownerName: "Mara", collectorName: nil, status: .open, createdAt: Date(), estimatedDeposit: 2.50)
    }

    func testOpenOfferCanBeClaimedThenCollected() throws {
        let offer = makeOpenOffer()
        let store = DemoOfferStore(offers: [offer])
        try store.claim(id: offer.id, collectorName: "Samir")
        XCTAssertEqual(store.offers[0].status, .claimed)
        XCTAssertEqual(store.offers[0].collectorName, "Samir")

        try store.markCollected(id: offer.id)
        XCTAssertEqual(store.offers[0].status, .collected)
    }

    func testCollectedOfferCannotBeClaimedAgain() throws {
        var offer = makeOpenOffer()
        offer.status = .collected
        let store = DemoOfferStore(offers: [offer])
        XCTAssertThrowsError(try store.claim(id: offer.id, collectorName: "Du"))
    }

    func testOpenOfferCanBeCancelledButNotCollectedDirectly() throws {
        let offer = makeOpenOffer()
        let store = DemoOfferStore(offers: [offer])
        XCTAssertThrowsError(try store.markCollected(id: offer.id))
        try store.cancel(id: offer.id)
        XCTAssertEqual(store.offers[0].status, .cancelled)
    }

    func testCreateRejectsInvalidDraft() {
        let store = DemoOfferStore(offers: [])
        var draft = OfferDraft()
        draft.bottleCount = 0
        draft.meetingPoint = nil
        XCTAssertThrowsError(try store.create(from: draft))
        XCTAssertTrue(store.offers.isEmpty)
    }
}
