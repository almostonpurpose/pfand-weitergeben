import Foundation

enum DemoData {
    private static let reference = Date()
    private static func fromNow(hours: Double) -> Date {
        reference.addingTimeInterval(hours * 3_600)
    }

    static let meetingPoints = [
        MeetingPoint(nameKey: "meeting.library", neighbourhoodKey: "district.neukoelln", latitude: 52.4808, longitude: 13.4354),
        MeetingPoint(nameKey: "meeting.park", neighbourhoodKey: "district.neukoelln", latitude: 52.4727, longitude: 13.4386),
        MeetingPoint(nameKey: "meeting.community", neighbourhoodKey: "district.kreuzberg", latitude: 52.4936, longitude: 13.4233),
        MeetingPoint(nameKey: "meeting.station", neighbourhoodKey: "district.neukoelln", latitude: 52.4867, longitude: 13.4245)
    ]

    static let offers: [Offer] = [
        Offer(id: UUID(uuidString: "1130C76A-640F-4C0B-9117-D29D49323101")!, bottleCount: 18, bagSize: .medium,
              pickupStart: fromNow(hours: 1), pickupEnd: fromNow(hours: 3), instructions: "", instructionsLocalizationKey: "demo.instructions.1", meetingPoint: meetingPoints[0], distanceMetres: 350, ownerName: "Mara", collectorName: nil, status: .open, createdAt: Date().addingTimeInterval(-900), estimatedDeposit: 4.50),
        Offer(id: UUID(uuidString: "1130C76A-640F-4C0B-9117-D29D49323102")!, bottleCount: 32, bagSize: .large,
              pickupStart: fromNow(hours: 18), pickupEnd: fromNow(hours: 20), instructions: "", instructionsLocalizationKey: "demo.instructions.2", meetingPoint: meetingPoints[1], distanceMetres: 750, ownerName: "Jens", collectorName: nil, status: .open, createdAt: Date().addingTimeInterval(-2_400), estimatedDeposit: 8.00),
        Offer(id: UUID(uuidString: "1130C76A-640F-4C0B-9117-D29D49323103")!, bottleCount: 9, bagSize: .small,
              pickupStart: fromNow(hours: 22), pickupEnd: fromNow(hours: 24), instructions: "", instructionsLocalizationKey: "demo.instructions.3", meetingPoint: meetingPoints[2], distanceMetres: 1_200, ownerName: "Leyla", collectorName: nil, status: .open, createdAt: Date().addingTimeInterval(-3_600), estimatedDeposit: 2.25),
        Offer(id: UUID(uuidString: "1130C76A-640F-4C0B-9117-D29D49323104")!, bottleCount: 24, bagSize: .large,
              pickupStart: fromNow(hours: 5), pickupEnd: fromNow(hours: 6), instructions: "", instructionsLocalizationKey: "demo.instructions.4", meetingPoint: meetingPoints[3], distanceMetres: 900, ownerName: "Tobias", collectorName: "Du", status: .claimed, createdAt: Date().addingTimeInterval(-7_200), estimatedDeposit: 6.00)
    ]
}
