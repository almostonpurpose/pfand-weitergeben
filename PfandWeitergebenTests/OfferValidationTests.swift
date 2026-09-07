import XCTest
@testable import PfandWeitergeben

final class OfferValidationTests: XCTestCase {
    func testValidDraftHasNoIssues() {
        var draft = OfferDraft()
        draft.pickupStart = Date().addingTimeInterval(3_600)
        draft.pickupEnd = Date().addingTimeInterval(7_200)
        draft.meetingPoint = DemoData.meetingPoints[0]
        draft.privateAddress = "Musterweg 12, 12043 Berlin"
        XCTAssertTrue(draft.validationIssues().isEmpty)
    }

    func testRejectsMissingMeetingPointAndInvalidCount() {
        var draft = OfferDraft()
        draft.depositBreakdown = DepositBreakdown()
        draft.meetingPoint = nil
        let issues = draft.validationIssues()
        XCTAssertTrue(issues.contains(.invalidBottleCount))
        XCTAssertTrue(issues.contains(.missingMeetingPoint))
    }

    func testRejectsEndBeforeStart() {
        var draft = OfferDraft()
        draft.pickupStart = Date().addingTimeInterval(7_200)
        draft.pickupEnd = Date().addingTimeInterval(3_600)
        draft.meetingPoint = DemoData.meetingPoints[0]
        XCTAssertTrue(draft.validationIssues().contains(.invalidTimeWindow))
    }

    func testRejectsInstructionsOverLimit() {
        var draft = OfferDraft()
        draft.instructions = String(repeating: "a", count: 281)
        draft.meetingPoint = DemoData.meetingPoints[0]
        XCTAssertTrue(draft.validationIssues().contains(.instructionsTooLong))
    }

    func testHomeCollectionRequiresAnAddress() {
        var draft = OfferDraft()
        draft.meetingPoint = DemoData.meetingPoints[0]
        draft.privateAddress = ""
        XCTAssertTrue(draft.validationIssues().contains(.missingPrivateAddress))
    }

    func testAgreedPlaceDoesNotRequireAHomeAddress() {
        var draft = OfferDraft()
        draft.handoverMethod = .agreedPlace
        draft.privateAddress = ""
        XCTAssertFalse(draft.validationIssues().contains(.missingPrivateAddress))
    }

    func testDepositBreakdownUsesEightFifteenAndTwentyFiveCentValues() {
        let breakdown = DepositBreakdown(reusableEight: 2, reusableFifteen: 3, singleUseTwentyFive: 4)
        XCTAssertEqual(breakdown.totalCount, 9)
        XCTAssertEqual(breakdown.estimatedValue, 1.61, accuracy: 0.001)
    }
}
