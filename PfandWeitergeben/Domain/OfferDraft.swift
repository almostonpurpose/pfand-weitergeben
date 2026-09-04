import Foundation

struct OfferDraft: Sendable {
    var depositBreakdown = DepositBreakdown(singleUseTwentyFive: 12)
    var bagSize: BagSize = .medium
    var pickupStart: Date
    var pickupEnd: Date
    var instructions = ""
    var meetingPoint: MeetingPoint? = DemoData.meetingPoints.first
    var handoverMethod: HandoverMethod = .atDoor
    var privateAddress = ""

    init(now: Date = Date()) {
        let candidate = now.nextQuarterHour.addingTimeInterval(45 * 60)
        let calendar = Calendar.current
        let start: Date
        if calendar.component(.hour, from: candidate) >= 23 {
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? candidate
            start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) ?? candidate
        } else {
            start = candidate
        }
        pickupStart = start
        pickupEnd = start.addingTimeInterval(60 * 60)
    }

    var bottleCount: Int { depositBreakdown.totalCount }
    var estimatedDeposit: Double { depositBreakdown.estimatedValue }

    func validationIssues(now: Date = Date()) -> [OfferValidationIssue] {
        var issues: [OfferValidationIssue] = []
        if !(1...200).contains(bottleCount) { issues.append(.invalidBottleCount) }
        if pickupEnd <= pickupStart { issues.append(.invalidTimeWindow) }
        if pickupEnd <= now { issues.append(.timeWindowInPast) }
        if instructions.count > 280 { issues.append(.instructionsTooLong) }
        if meetingPoint == nil { issues.append(.missingMeetingPoint) }
        if handoverMethod.requiresPrivateAddress && privateAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(.missingPrivateAddress)
        }
        if estimatedDeposit > 100 { issues.append(.invalidDepositEstimate) }
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
    case missingPrivateAddress
    case invalidDepositEstimate

    var message: String {
        switch self {
        case .invalidBottleCount: L10n.string("validation.bottle_count")
        case .invalidTimeWindow: L10n.string("validation.time_window")
        case .timeWindowInPast: L10n.string("validation.time_past")
        case .instructionsTooLong: L10n.string("validation.instructions")
        case .missingMeetingPoint: L10n.string("validation.meeting_point")
        case .missingPrivateAddress: L10n.string("validation.private_address")
        case .invalidDepositEstimate: L10n.string("validation.deposit")
        }
    }
}

private extension Date {
    var nextQuarterHour: Date {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: self)
        let seconds = calendar.component(.second, from: self)
        let remainder = minute % 15
        let minutesToAdd = remainder == 0 && seconds == 0 ? 0 : 15 - remainder
        let withoutSeconds = calendar.date(bySetting: .second, value: 0, of: self) ?? self
        return calendar.date(byAdding: .minute, value: minutesToAdd, to: withoutSeconds) ?? self
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
