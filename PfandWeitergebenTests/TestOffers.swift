import Foundation
@testable import PfandWeitergeben

enum TestOffers {
    static let mara = Participant(id: "demo-mara", name: "Mara")
    static let samir = Participant(id: "test-samir", name: "Samir")

    /// Whole seconds, because the on-disk format is ISO 8601 without fractions.
    static var now: Date { Date(timeIntervalSince1970: Date().timeIntervalSince1970.rounded(.down)) }

    static func open(id: UUID = UUID(), owner: Participant = mara, handover: HandoverMethod = .atDoor) -> Offer {
        Offer(id: id, depositBreakdown: DepositBreakdown(singleUseTwentyFive: 10), bagSize: .medium,
              pickupStart: now.addingTimeInterval(3_600), pickupEnd: now.addingTimeInterval(7_200),
              instructions: "", meetingPoint: DemoData.meetingPoints[0],
              handoverMethod: handover, privateAddress: handover.requiresPrivateAddress ? "Musterweg 12, 12043 Berlin" : nil,
              distanceMetres: 100, owner: owner, collector: nil,
              status: .open, createdAt: now)
    }
}
