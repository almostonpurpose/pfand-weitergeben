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
    var bottleCount: Int
    var bagSize: BagSize
    var pickupStart: Date
    var pickupEnd: Date
    var instructions: String
    var instructionsLocalizationKey: String? = nil
    var meetingPoint: MeetingPoint
    var distanceMetres: Int
    var ownerName: String
    var collectorName: String?
    var status: OfferStatus
    var createdAt: Date

    var estimatedDeposit: Double
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
}
