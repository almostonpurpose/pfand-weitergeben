import Foundation
import CoreLocation

enum ReturnPointKind: String, CaseIterable, Codable, Sendable {
    case supermarket
    case glassRecycling

    var title: String {
        switch self {
        case .supermarket: L10n.string("return.kind.supermarket")
        case .glassRecycling: L10n.string("return.kind.glass")
        }
    }

    var symbol: String {
        switch self {
        case .supermarket: "cart.fill"
        case .glassRecycling: "arrow.3.trianglepath"
        }
    }
}

enum ReturnPointEvidence: String, Codable, Sendable {
    case supermarketLocation
    case bottleReturnMachine
    case glassBottleRecycling

    var note: String {
        switch self {
        case .supermarketLocation:
            L10n.string("return.evidence.supermarket")
        case .bottleReturnMachine:
            L10n.string("return.evidence.bottle_return")
        case .glassBottleRecycling:
            L10n.string("return.evidence.glass")
        }
    }
}

struct ReturnPoint: Identifiable, Codable, Sendable {
    let id: String
    let kind: ReturnPointKind
    let evidence: ReturnPointEvidence
    let name: String?
    let area: String
    let latitude: Double
    let longitude: Double

    var displayName: String {
        guard let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            switch evidence {
            case .supermarketLocation: return L10n.string("return.generic.supermarket")
            case .bottleReturnMachine: return L10n.string("return.generic.bottle_return")
            case .glassBottleRecycling: return L10n.string("return.generic.glass")
            }
        }
        return name
    }

    var displayArea: String {
        area.isEmpty ? L10n.string("return.area.berlin") : area
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

protocol ReturnPointProviding: Sendable {
    var returnPoints: [ReturnPoint] { get }
    var attribution: String { get }
    var isSampleData: Bool { get }
    var sourceURL: URL? { get }
}

private struct ReturnPointSnapshot: Decodable {
    let source: String
    let license: String
    let sourceURL: URL
    let snapshotDate: String
    let points: [ReturnPoint]
}

struct BundledBerlinReturnPointProvider: ReturnPointProviding {
    let returnPoints: [ReturnPoint]
    let isSampleData = false
    let sourceURL: URL?
    private let snapshotDate: String

    var attribution: String {
        L10n.string("return.osm_attribution", snapshotDate)
    }

    init(bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: "berlin-return-points", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let snapshot = try? JSONDecoder().decode(ReturnPointSnapshot.self, from: data) else {
            returnPoints = []
            sourceURL = URL(string: "https://www.openstreetmap.org/copyright")
            snapshotDate = "2026-09-07"
            return
        }
        returnPoints = snapshot.points
        sourceURL = snapshot.sourceURL
        snapshotDate = snapshot.snapshotDate
    }
}
