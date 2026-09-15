import XCTest
@testable import PfandWeitergeben

final class OfferPersistenceTests: XCTestCase {
    private var persistence: OfferPersistence!

    override func setUp() {
        super.setUp()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("pfand-tests-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("offers.json")
        persistence = OfferPersistence(fileURL: url)
    }

    override func tearDown() {
        persistence.clear()
        super.tearDown()
    }

    func testOffersSurviveARoundTrip() {
        var claimed = TestOffers.open(handover: .leaveAtDoor)
        claimed.collector = TestOffers.samir
        claimed.handoverCode = "3141"
        claimed.status = .claimed
        let offers = [TestOffers.open(), claimed]

        persistence.save(offers)
        XCTAssertEqual(persistence.load(), offers)
    }

    func testMissingOrUnreadableFileCountsAsAbsent() throws {
        XCTAssertNil(persistence.load())
        try FileManager.default.createDirectory(at: persistence.fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("{not json".utf8).write(to: persistence.fileURL)
        XCTAssertNil(persistence.load())
    }

    func testMergeKeepsChangesAndRefreshesUntouchedDemoOffers() {
        let demoID = UUID()
        var staleDemo = TestOffers.open(id: demoID)
        staleDemo.pickupStart = Date().addingTimeInterval(-86_400)
        staleDemo.pickupEnd = Date().addingTimeInterval(-82_800)
        let freshDemo = TestOffers.open(id: demoID)

        var claimedDemo = TestOffers.open(id: UUID())
        claimedDemo.status = .claimed
        claimedDemo.collector = LocalIdentity.participant
        claimedDemo.handoverCode = "2718"
        var seedForClaimed = claimedDemo
        seedForClaimed.status = .open
        seedForClaimed.collector = nil
        seedForClaimed.handoverCode = nil

        let mine = TestOffers.open(owner: LocalIdentity.participant)
        let newSeedEntry = TestOffers.open()

        let merged = OfferPersistence.merge(
            stored: [staleDemo, claimedDemo, mine],
            seed: [freshDemo, seedForClaimed, newSeedEntry]
        )

        XCTAssertEqual(merged.count, 4)
        XCTAssertEqual(merged.first { $0.id == demoID }?.pickupStart, freshDemo.pickupStart)
        XCTAssertEqual(merged.first { $0.id == claimedDemo.id }?.status, .claimed)
        XCTAssertEqual(merged.first { $0.id == claimedDemo.id }?.handoverCode, "2718")
        XCTAssertTrue(merged.contains(mine))
        XCTAssertTrue(merged.contains(newSeedEntry))
    }
}
