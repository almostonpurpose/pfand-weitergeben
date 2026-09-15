import XCTest
@testable import PfandWeitergeben

final class LocalIdentityTests: XCTestCase {
    override func tearDown() {
        UserDefaults.standard.set("de", forKey: "appLanguage")
        UserDefaults.standard.removeObject(forKey: LocalIdentity.displayNameKey)
        super.tearDown()
    }

    func testIdentifierIsCreatedOnceAndStaysStable() {
        let first = LocalIdentity.id
        XCTAssertFalse(first.isEmpty)
        XCTAssertEqual(LocalIdentity.id, first)
        XCTAssertEqual(LocalIdentity.participant.id, first)
    }

    func testPersonOnThisDeviceIsShownAsYouWhateverTheirName() {
        UserDefaults.standard.set("de", forKey: "appLanguage")
        UserDefaults.standard.set("Amr", forKey: LocalIdentity.displayNameKey)
        let me = LocalIdentity.participant
        XCTAssertEqual(me.name, "Amr")
        XCTAssertTrue(me.isMe)
        XCTAssertEqual(me.displayName, "Du")
    }

    func testNeighbourWithoutNameGetsNeutralLabel() {
        UserDefaults.standard.set("de", forKey: "appLanguage")
        let unnamed = Participant(id: "someone-else", name: "  ")
        XCTAssertFalse(unnamed.isMe)
        XCTAssertEqual(unnamed.displayName, "Nachbar:in")
        XCTAssertEqual(Participant(id: "someone-else", name: "Leyla").displayName, "Leyla")
    }

    func testHandoverCodeHasFourDigitsAndMatchesExactly() {
        for _ in 0..<50 {
            let code = HandoverCode.generate()
            XCTAssertEqual(code.count, 4)
            XCTAssertTrue(code.allSatisfy(\.isNumber))
        }
        XCTAssertTrue(HandoverCode.matches(" 0042 ", "0042"))
        XCTAssertFalse(HandoverCode.matches("42", "0042"))
        XCTAssertFalse(HandoverCode.matches("0042", nil))
    }
}
