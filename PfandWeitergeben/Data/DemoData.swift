import Foundation

enum DemoData {
    private static let reference: Date = {
        let now = Date()
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: now)
        let add = 15 - (minute % 15)
        let base = calendar.date(bySetting: .second, value: 0, of: now) ?? now
        return calendar.date(byAdding: .minute, value: add, to: base) ?? now
    }()

    private static func fromNow(minutes: Int) -> Date {
        reference.addingTimeInterval(Double(minutes * 60))
    }

    private static func neighbour(_ name: String) -> Participant {
        Participant(id: "demo-\(name.lowercased())", name: name)
    }

    static let meetingPoints = [
        MeetingPoint(nameKey: "meeting.neukoelln", neighbourhoodKey: "district.neukoelln", latitude: 52.4808, longitude: 13.4354),
        MeetingPoint(nameKey: "meeting.kreuzberg", neighbourhoodKey: "district.kreuzberg", latitude: 52.4990, longitude: 13.4180),
        MeetingPoint(nameKey: "meeting.mitte", neighbourhoodKey: "district.mitte", latitude: 52.5208, longitude: 13.4095),
        MeetingPoint(nameKey: "meeting.friedrichshain", neighbourhoodKey: "district.friedrichshain", latitude: 52.5158, longitude: 13.4540),
        MeetingPoint(nameKey: "meeting.prenzlauerberg", neighbourhoodKey: "district.prenzlauerberg", latitude: 52.5405, longitude: 13.4245),
        MeetingPoint(nameKey: "meeting.wedding", neighbourhoodKey: "district.wedding", latitude: 52.5505, longitude: 13.3680),
        MeetingPoint(nameKey: "meeting.schoeneberg", neighbourhoodKey: "district.schoeneberg", latitude: 52.4862, longitude: 13.3497),
        MeetingPoint(nameKey: "meeting.charlottenburg", neighbourhoodKey: "district.charlottenburg", latitude: 52.5060, longitude: 13.3050),
        MeetingPoint(nameKey: "meeting.moabit", neighbourhoodKey: "district.moabit", latitude: 52.5250, longitude: 13.3420)
    ]

    static let offers: [Offer] = [
        Offer(id: UUID(uuidString: "1130C76A-640F-4C0B-9117-D29D49323101")!,
              depositBreakdown: DepositBreakdown(reusableEight: 6, reusableFifteen: 2, singleUseTwentyFive: 10), bagSize: .medium,
              pickupStart: fromNow(minutes: 60), pickupEnd: fromNow(minutes: 120), instructions: "", instructionsLocalizationKey: "demo.instructions.1",
              meetingPoint: meetingPoints[0], handoverMethod: .leaveAtDoor, privateAddress: "Musterweg 12, 12043 Berlin",
              distanceMetres: 350, owner: neighbour("Mara"), collector: nil, status: .open, createdAt: Date().addingTimeInterval(-900)),
        Offer(id: UUID(uuidString: "1130C76A-640F-4C0B-9117-D29D49323102")!,
              depositBreakdown: DepositBreakdown(singleUseTwentyFive: 32), bagSize: .large,
              pickupStart: fromNow(minutes: 180), pickupEnd: fromNow(minutes: 240), instructions: "", instructionsLocalizationKey: "demo.instructions.2",
              meetingPoint: meetingPoints[2], handoverMethod: .atDoor, privateAddress: "Beispielallee 8, 10178 Berlin",
              distanceMetres: 2_400, owner: neighbour("Jens"), collector: nil, status: .open, createdAt: Date().addingTimeInterval(-2_400)),
        Offer(id: UUID(uuidString: "1130C76A-640F-4C0B-9117-D29D49323103")!,
              depositBreakdown: DepositBreakdown(reusableEight: 9), bagSize: .small,
              pickupStart: fromNow(minutes: 300), pickupEnd: fromNow(minutes: 345), instructions: "", instructionsLocalizationKey: "demo.instructions.3",
              meetingPoint: meetingPoints[3], handoverMethod: .agreedPlace, privateAddress: nil,
              distanceMetres: 3_100, owner: neighbour("Leyla"), collector: nil, status: .open, createdAt: Date().addingTimeInterval(-3_600)),
        Offer(id: UUID(uuidString: "1130C76A-640F-4C0B-9117-D29D49323104")!,
              depositBreakdown: DepositBreakdown(reusableFifteen: 8, singleUseTwentyFive: 16), bagSize: .large,
              pickupStart: fromNow(minutes: 150), pickupEnd: fromNow(minutes: 210), instructions: "", instructionsLocalizationKey: "demo.instructions.4",
              meetingPoint: meetingPoints[4], handoverMethod: .leaveAtDoor, privateAddress: "Demostraße 24, 10405 Berlin",
              distanceMetres: 4_200, owner: neighbour("Tobias"), collector: LocalIdentity.participant, status: .claimed, createdAt: Date().addingTimeInterval(-7_200), handoverCode: "7342"),
        Offer(id: UUID(uuidString: "1130C76A-640F-4C0B-9117-D29D49323105")!,
              depositBreakdown: DepositBreakdown(reusableEight: 12, reusableFifteen: 6), bagSize: .medium,
              pickupStart: fromNow(minutes: 420), pickupEnd: fromNow(minutes: 480), instructions: "", instructionsLocalizationKey: "demo.instructions.5",
              meetingPoint: meetingPoints[5], handoverMethod: .atDoor, privateAddress: "Testufer 5, 13353 Berlin",
              distanceMetres: 5_600, owner: neighbour("Aylin"), collector: nil, status: .open, createdAt: Date().addingTimeInterval(-4_800)),
        Offer(id: UUID(uuidString: "1130C76A-640F-4C0B-9117-D29D49323106")!,
              depositBreakdown: DepositBreakdown(singleUseTwentyFive: 20), bagSize: .medium,
              pickupStart: fromNow(minutes: 510), pickupEnd: fromNow(minutes: 555), instructions: "", instructionsLocalizationKey: "demo.instructions.6",
              meetingPoint: meetingPoints[6], handoverMethod: .leaveAtDoor, privateAddress: "Beispielplatz 3, 10827 Berlin",
              distanceMetres: 6_300, owner: neighbour("Nora"), collector: nil, status: .open, createdAt: Date().addingTimeInterval(-5_400)),
        Offer(id: UUID(uuidString: "1130C76A-640F-4C0B-9117-D29D49323107")!,
              depositBreakdown: DepositBreakdown(reusableEight: 10, reusableFifteen: 10, singleUseTwentyFive: 10), bagSize: .large,
              pickupStart: fromNow(minutes: 600), pickupEnd: fromNow(minutes: 690), instructions: "", instructionsLocalizationKey: "demo.instructions.7",
              meetingPoint: meetingPoints[7], handoverMethod: .atDoor, privateAddress: "Musterstraße 40, 10627 Berlin",
              distanceMetres: 7_800, owner: neighbour("Can"), collector: nil, status: .open, createdAt: Date().addingTimeInterval(-6_300)),
        Offer(id: UUID(uuidString: "1130C76A-640F-4C0B-9117-D29D49323108")!,
              depositBreakdown: DepositBreakdown(reusableFifteen: 5, singleUseTwentyFive: 8), bagSize: .small,
              pickupStart: fromNow(minutes: 720), pickupEnd: fromNow(minutes: 765), instructions: "", instructionsLocalizationKey: "demo.instructions.8",
              meetingPoint: meetingPoints[8], handoverMethod: .agreedPlace, privateAddress: nil,
              distanceMetres: 5_100, owner: neighbour("Omar"), collector: nil, status: .open, createdAt: Date().addingTimeInterval(-7_000))
    ]
}
