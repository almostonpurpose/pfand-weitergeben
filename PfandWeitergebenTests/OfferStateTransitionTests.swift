import XCTest
@testable import PfandWeitergeben

@MainActor
final class OfferStateTransitionTests: XCTestCase {
    func testOpenOfferCanBeClaimedThenCollectedWithTheHandoverCode() throws {
        let offer = TestOffers.open()
        let store = DemoOfferStore(offers: [offer])

        let code = try store.claim(id: offer.id)
        XCTAssertEqual(store.offers[0].status, .claimed)
        XCTAssertEqual(store.offers[0].collector?.id, LocalIdentity.id)
        XCTAssertEqual(store.offers[0].handoverCode, code)
        XCTAssertEqual(code.count, 4)

        let wrongCode = code == "0000" ? "1111" : "0000"
        XCTAssertThrowsError(try store.markCollected(id: offer.id, handoverCode: wrongCode)) { error in
            XCTAssertEqual(error as? OfferStoreError, .wrongHandoverCode)
        }
        XCTAssertEqual(store.offers[0].status, .claimed)

        try store.markCollected(id: offer.id, handoverCode: code)
        XCTAssertEqual(store.offers[0].status, .collected)
    }

    func testContactlessPickupAlsoNeedsTheCode() throws {
        let offer = TestOffers.open(handover: .leaveAtDoor)
        let store = DemoOfferStore(offers: [offer])
        let code = try store.claim(id: offer.id)
        XCTAssertThrowsError(try store.markCollected(id: offer.id, handoverCode: ""))
        try store.markCollected(id: offer.id, handoverCode: " \(code) ")
        XCTAssertEqual(store.offers[0].status, .collected)
    }

    func testCollectedOfferCannotBeClaimedAgain() throws {
        var offer = TestOffers.open()
        offer.status = .collected
        let store = DemoOfferStore(offers: [offer])
        XCTAssertThrowsError(try store.claim(id: offer.id))
    }

    func testOpenOfferCanBeCancelledButNotCollectedDirectly() throws {
        let offer = TestOffers.open()
        let store = DemoOfferStore(offers: [offer])
        XCTAssertThrowsError(try store.markCollected(id: offer.id, handoverCode: "1234")) { error in
            XCTAssertEqual(error as? OfferStoreError, .transition(.invalidTransition(from: .open, to: .collected)))
        }
        try store.cancel(id: offer.id)
        XCTAssertEqual(store.offers[0].status, .cancelled)
    }

    func testCreatedOfferBelongsToThisDevice() throws {
        let store = DemoOfferStore(offers: [])
        var draft = OfferDraft()
        draft.privateAddress = "Musterweg 12, 12043 Berlin"
        let offer = try store.create(from: draft)
        XCTAssertTrue(offer.isMine)
        XCTAssertEqual(offer.owner.id, LocalIdentity.id)
        XCTAssertNil(offer.collector)
        XCTAssertNil(offer.handoverCode)
    }

    func testCreateRejectsInvalidDraft() {
        let store = DemoOfferStore(offers: [])
        var draft = OfferDraft()
        draft.depositBreakdown = DepositBreakdown()
        draft.meetingPoint = nil
        XCTAssertThrowsError(try store.create(from: draft))
        XCTAssertTrue(store.offers.isEmpty)
    }

    func testAcceptedOfferSurvivesRelaunch() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("pfand-store-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("offers.json")
        let persistence = OfferPersistence(fileURL: url)
        defer { persistence.clear() }

        let first = DemoOfferStore(persistence: persistence)
        guard let open = first.offers.first(where: { $0.status == .open }) else { return XCTFail("demo seed has no open offer") }
        let code = try first.claim(id: open.id)

        let relaunched = DemoOfferStore(persistence: persistence)
        let restored = relaunched.offers.first { $0.id == open.id }
        XCTAssertEqual(restored?.status, .claimed)
        XCTAssertEqual(restored?.handoverCode, code)
        XCTAssertEqual(restored?.collector?.id, LocalIdentity.id)

        relaunched.resetDemo()
        XCTAssertEqual(relaunched.offers.first { $0.id == open.id }?.status, .open)
    }
}
