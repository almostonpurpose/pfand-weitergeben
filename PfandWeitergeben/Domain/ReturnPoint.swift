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
                    nameKey: "return.supermarket.mitte", areaKey: "district.mitte",
                    latitude: 52.5217, longitude: 13.4110),
        ReturnPoint(id: UUID(uuidString: "A130C76A-640F-4C0B-9117-D29D49323103")!, kind: .supermarket,
                    nameKey: "return.supermarket.friedrichshain", areaKey: "district.friedrichshain",
                    latitude: 52.5165, longitude: 13.4548),
        ReturnPoint(id: UUID(uuidString: "A130C76A-640F-4C0B-9117-D29D49323104")!, kind: .supermarket,
                    nameKey: "return.supermarket.wedding", areaKey: "district.wedding",
                    latitude: 52.5513, longitude: 13.3674),
        ReturnPoint(id: UUID(uuidString: "A130C76A-640F-4C0B-9117-D29D49323105")!, kind: .supermarket,
                    nameKey: "return.supermarket.schoeneberg", areaKey: "district.schoeneberg",
                    latitude: 52.4873, longitude: 13.3515),
        ReturnPoint(id: UUID(uuidString: "A130C76A-640F-4C0B-9117-D29D49323106")!, kind: .supermarket,
                    nameKey: "return.supermarket.charlottenburg", areaKey: "district.charlottenburg",
                    latitude: 52.5052, longitude: 13.3058),
        ReturnPoint(id: UUID(uuidString: "B130C76A-640F-4C0B-9117-D29D49323101")!, kind: .glassRecycling,
                    nameKey: "return.glass.karlmarx", areaKey: "district.neukoelln",
                    latitude: 52.4746, longitude: 13.4405),
        ReturnPoint(id: UUID(uuidString: "B130C76A-640F-4C0B-9117-D29D49323102")!, kind: .glassRecycling,
                    nameKey: "return.glass.kreuzberg", areaKey: "district.kreuzberg",
                    latitude: 52.4945, longitude: 13.4105),
        ReturnPoint(id: UUID(uuidString: "B130C76A-640F-4C0B-9117-D29D49323103")!, kind: .glassRecycling,
                    nameKey: "return.glass.prenzlauerberg", areaKey: "district.prenzlauerberg",
                    latitude: 52.5413, longitude: 13.4258),
        ReturnPoint(id: UUID(uuidString: "B130C76A-640F-4C0B-9117-D29D49323104")!, kind: .glassRecycling,
                    nameKey: "return.glass.moabit", areaKey: "district.moabit",
                    latitude: 52.5242, longitude: 13.3407),
        ReturnPoint(id: UUID(uuidString: "B130C76A-640F-4C0B-9117-D29D49323105")!, kind: .glassRecycling,
                    nameKey: "return.glass.wedding", areaKey: "district.wedding",
                    latitude: 52.5488, longitude: 13.3710),
        ReturnPoint(id: UUID(uuidString: "B130C76A-640F-4C0B-9117-D29D49323106")!, kind: .glassRecycling,
                    nameKey: "return.glass.schoeneberg", areaKey: "district.schoeneberg",
                    latitude: 52.4848, longitude: 13.3482)
    ]
}
