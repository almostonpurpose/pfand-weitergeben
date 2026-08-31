import XCTest
@testable import PfandWeitergeben

final class OfferValidationTests: XCTestCase {
    func testValidDraftHasNoIssues() {
        var draft = OfferDraft()
        draft.pickupStart = Date().addingTimeInterval(3_600)
        draft.pickupEnd = Date().addingTimeInterval(7_200)
        draft.meetingPoint = DemoData.meetingPoints[0]
        XCTAssertTrue(draft.validationIssues().isEmpty)
    }

    func testRejectsMissingMeetingPointAndInvalidCount() {
        var draft = OfferDraft()
        draft.bottleCount = 0
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

    func testRejectsDepositOutsideEditableRange() {
        var draft = OfferDraft()
        draft.estimatedDeposit = 101
        draft.meetingPoint = DemoData.meetingPoints[0]
        XCTAssertTrue(draft.validationIssues().contains(.invalidDepositEstimate))
    }
}

