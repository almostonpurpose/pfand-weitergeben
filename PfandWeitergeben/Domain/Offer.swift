import Foundation
import CoreLocation

struct MeetingPoint: Codable, Hashable, Sendable {
    var nameKey: String
    var neighbourhoodKey: String
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var name: String { L10n.string(nameKey) }
    var neighbourhood: String { L10n.string(neighbourhoodKey) }
}

enum DepositType: String, CaseIterable, Codable, Identifiable, Sendable {
    case reusableEight
    case reusableFifteen
    case singleUseTwentyFive

    var id: Self { self }
    var cents: Int {
        switch self {
        case .reusableEight: 8
        case .reusableFifteen: 15
        case .singleUseTwentyFive: 25
        }
    }
    var title: String {
        switch self {
        case .reusableEight: L10n.string("deposit.reusable_8")
        case .reusableFifteen: L10n.string("deposit.reusable_15")
        case .singleUseTwentyFive: L10n.string("deposit.single_use_25")
        }
    }
    var note: String {
        switch self {
        case .reusableEight: L10n.string("deposit.reusable_8_note")
        case .reusableFifteen: L10n.string("deposit.reusable_15_note")
        case .singleUseTwentyFive: L10n.string("deposit.single_use_25_note")
        }
    }
}

struct DepositBreakdown: Codable, Hashable, Sendable {
    var reusableEight: Int = 0
    var reusableFifteen: Int = 0
    var singleUseTwentyFive: Int = 0

    var totalCount: Int { reusableEight + reusableFifteen + singleUseTwentyFive }
    var estimatedValue: Double {
        Double(reusableEight * 8 + reusableFifteen * 15 + singleUseTwentyFive * 25) / 100
    }

    func count(for type: DepositType) -> Int {
        switch type {
        case .reusableEight: reusableEight
        case .reusableFifteen: reusableFifteen
        case .singleUseTwentyFive: singleUseTwentyFive
        }
    }

    mutating func setCount(_ count: Int, for type: DepositType) {
        let bounded = min(max(count, 0), 200)
        switch type {
        case .reusableEight: reusableEight = bounded
        case .reusableFifteen: reusableFifteen = bounded
        case .singleUseTwentyFive: singleUseTwentyFive = bounded
        }
    }
}

enum HandoverMethod: String, CaseIterable, Codable, Identifiable, Sendable {
    case atDoor
    case leaveAtDoor
    case agreedPlace

    var id: Self { self }
    var title: String {
        switch self {
        case .atDoor: L10n.string("handover.at_door")
        case .leaveAtDoor: L10n.string("handover.leave_at_door")
        case .agreedPlace: L10n.string("handover.agreed_place")
        }
    }
    var note: String {
        switch self {
        case .atDoor: L10n.string("handover.at_door_note")
        case .leaveAtDoor: L10n.string("handover.leave_at_door_note")
        case .agreedPlace: L10n.string("handover.agreed_place_note")
        }
    }
    var symbol: String {
        switch self {
        case .atDoor: "door.left.hand.open"
        case .leaveAtDoor: "shippingbox"
        case .agreedPlace: "mappin.and.ellipse"
        }
    }
    var requiresPrivateAddress: Bool { self != .agreedPlace }
}

enum BagSize: String, CaseIterable, Codable, Identifiable, Sendable {
    case small, medium, large, several

    var id: Self { self }
    var title: String {
        switch self {
        case .small: L10n.string("bag.small")
        case .medium: L10n.string("bag.medium")
        case .large: L10n.string("bag.large")
        case .several: L10n.string("bag.several")
        }
    }
    var symbol: String {
        switch self {
        case .small: "takeoutbag.and.cup.and.straw"
        case .medium: "bag"
        case .large: "bag.fill"
        case .several: "shippingbox.and.arrow.backward"
        }
    }
}

enum OfferStatus: String, Codable, CaseIterable, Sendable {
    case open, claimed, collected, cancelled

    var title: String {
        switch self {
        case .open: L10n.string("status.open")
        case .claimed: L10n.string("status.claimed")
        case .collected: L10n.string("status.collected")
        case .cancelled: L10n.string("status.cancelled")
        }
    }
}

struct Offer: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var depositBreakdown: DepositBreakdown
    var bagSize: BagSize
    var pickupStart: Date
    var pickupEnd: Date
    var instructions: String
    var instructionsLocalizationKey: String? = nil
    var meetingPoint: MeetingPoint
    var handoverMethod: HandoverMethod
    var privateAddress: String?
    var distanceMetres: Int
    var owner: Participant
    var collector: Participant?
    var status: OfferStatus
    var createdAt: Date
    /// Four digits created when someone accepts; entering them marks the offer collected.
    var handoverCode: String? = nil

    var isMine: Bool { owner.isMe }
    var isCollectedByMe: Bool { collector?.isMe == true }
    var involvesMe: Bool { isMine || isCollectedByMe }

    var bottleCount: Int { depositBreakdown.totalCount }
    var estimatedDeposit: Double { depositBreakdown.estimatedValue }
    var displayInstructions: String {
        instructionsLocalizationKey.map { L10n.string($0) } ?? instructions
    }
    var distanceText: String {
        distanceMetres < 1_000 ? L10n.string("distance.metres", distanceMetres) : L10n.string("distance.kilometres", Double(distanceMetres) / 1_000)
    }
    var pickupTimeText: String {
        let day = pickupStart.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).locale(L10n.locale))
        let start = pickupStart.formatted(.dateTime.hour().minute().locale(L10n.locale))
        let end = pickupEnd.formatted(.dateTime.hour().minute().locale(L10n.locale))
        return L10n.string("pickup.window", day, start, end)
    }
    var confirmedPickupLocation: String {
        if handoverMethod.requiresPrivateAddress, let privateAddress, !privateAddress.isEmpty {
            return privateAddress
        }
        return meetingPoint.name
    }
}
