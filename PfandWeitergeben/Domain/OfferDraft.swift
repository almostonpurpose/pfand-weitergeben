import Foundation

struct OfferDraft: Sendable {
    var bottleCount = 12
    var bagSize: BagSize = .medium
    var pickupStart = Date().addingTimeInterval(3_600)
    var pickupEnd = Date().addingTimeInterval(7_200)
    var instructions = ""
    var meetingPoint: MeetingPoint?
    var estimatedDeposit = 3.0

    func validationIssues(now: Date = Date()) -> [OfferValidationIssue] {
        var issues: [OfferValidationIssue] = []
        if !(1...200).contains(bottleCount) { issues.append(.invalidBottleCount) }
        if pickupEnd <= pickupStart { issues.append(.invalidTimeWindow) }
        if pickupEnd <= now { issues.append(.timeWindowInPast) }
        if instructions.count > 280 { issues.append(.instructionsTooLong) }
        if meetingPoint == nil { issues.append(.missingMeetingPoint) }
        if estimatedDeposit < 0 || estimatedDeposit > 100 { issues.append(.invalidDepositEstimate) }
        return issues
    }

    var isValid: Bool { validationIssues().isEmpty }
}

enum OfferValidationIssue: Error, Equatable, Sendable {
    case invalidBottleCount
    case invalidTimeWindow
    case timeWindowInPast
    case instructionsTooLong
    case missingMeetingPoint
    case invalidDepositEstimate

    var message: String {
        switch self {
        case .invalidBottleCount: L10n.string("validation.bottle_count")
        case .invalidTimeWindow: L10n.string("validation.time_window")
        case .timeWindowInPast: L10n.string("validation.time_past")
        case .instructionsTooLong: L10n.string("validation.instructions")
        case .missingMeetingPoint: L10n.string("validation.meeting_point")
        case .invalidDepositEstimate: L10n.string("validation.deposit")
        }
    }
}

enum OfferTransitionError: Error, Equatable, Sendable {
    case invalidTransition(from: OfferStatus, to: OfferStatus)
}

extension OfferStatus {
    func canTransition(to next: OfferStatus) -> Bool {
        switch (self, next) {
        case (.open, .claimed), (.open, .cancelled), (.claimed, .collected), (.claimed, .cancelled): true
        default: false
        }
    }
}
