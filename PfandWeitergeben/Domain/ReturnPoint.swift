import Foundation
import CoreLocation

enum ReturnPointKind: String, CaseIterable, Sendable {
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

struct ReturnPoint: Identifiable, Sendable {
    let id: UUID
    let kind: ReturnPointKind
    let nameKey: String
    let areaKey: String
    let latitude: Double
    let longitude: Double

    var name: String { L10n.string(nameKey) }
    var area: String { L10n.string(areaKey) }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

protocol ReturnPointProviding: Sendable {
    var returnPoints: [ReturnPoint] { get }
    var attribution: String { get }
    var isSampleData: Bool { get }
}

struct DemoReturnPointProvider: ReturnPointProviding {
    let isSampleData = true
    var attribution: String { L10n.string("return.demo_attribution") }

    let returnPoints: [ReturnPoint] = [
        ReturnPoint(id: UUID(uuidString: "A130C76A-640F-4C0B-9117-D29D49323101")!, kind: .supermarket,
                    nameKey: "return.supermarket.hermannplatz", areaKey: "district.neukoelln",
                    latitude: 52.4861, longitude: 13.4249),
        ReturnPoint(id: UUID(uuidString: "A130C76A-640F-4C0B-9117-D29D49323102")!, kind: .supermarket,
                    nameKey: "return.supermarket.karlmarx", areaKey: "district.neukoelln",
                    latitude: 52.4768, longitude: 13.4390),
        ReturnPoint(id: UUID(uuidString: "A130C76A-640F-4C0B-9117-D29D49323103")!, kind: .supermarket,
                    nameKey: "return.supermarket.kottbusser", areaKey: "district.kreuzberg",
                    latitude: 52.4992, longitude: 13.4181),
        ReturnPoint(id: UUID(uuidString: "B130C76A-640F-4C0B-9117-D29D49323101")!, kind: .glassRecycling,
                    nameKey: "return.glass.karlmarx", areaKey: "district.neukoelln",
                    latitude: 52.4746, longitude: 13.4405),
        ReturnPoint(id: UUID(uuidString: "B130C76A-640F-4C0B-9117-D29D49323102")!, kind: .glassRecycling,
                    nameKey: "return.glass.maybachufer", areaKey: "district.neukoelln",
                    latitude: 52.4905, longitude: 13.4302),
        ReturnPoint(id: UUID(uuidString: "B130C76A-640F-4C0B-9117-D29D49323103")!, kind: .glassRecycling,
                    nameKey: "return.glass.urbanstrasse", areaKey: "district.kreuzberg",
                    latitude: 52.4938, longitude: 13.4118)
    ]
}

