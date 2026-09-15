import XCTest
@testable import PfandWeitergeben

final class LocalizationTests: XCTestCase {
    override func tearDown() {
        UserDefaults.standard.set("de", forKey: "appLanguage")
        super.tearDown()
    }

    func testAllSupportedLanguagesContainSameKeys() {
        let languages = ["de", "en", "ar", "tr"]
        let dictionaries = languages.map { language -> Set<String> in
            guard let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language),
                  let dictionary = NSDictionary(contentsOfFile: path) as? [String: String] else {
                XCTFail("Missing Localizable.strings for \(language)")
                return []
            }
            return Set(dictionary.keys)
        }
        guard let germanKeys = dictionaries.first else { return }
        for (index, keys) in dictionaries.enumerated() {
            XCTAssertEqual(keys, germanKeys, "Key mismatch for \(languages[index])")
        }
    }

    func testSafetyCameraDepositAndMapMessagesExistInEveryLanguage() {
        let required = [
            "Annehmen und Pfand behalten",
            "Grobe Schätzung – kann falsch sein. Passe die Gesamtzahl an und verteile sie unten auf die Pfandarten.",
            "Das Foto bleibt auf deinem Gerät und wird nicht hochgeladen.",
            "handover.at_door",
            "handover.leave_at_door",
            "validation.private_address",
            "Optionale Kartenebenen",
            "OpenStreetMap-Daten; nicht vollständig und ohne Echtzeit-Öffnungszeiten.",
            "return.kind.supermarket",
            "return.kind.glass",
            "return.osm_attribution",
            "Hilfe in Berlin",
            "Kältebus · 030 690 333 690",
            "Kältehilfe-Wegweiser öffnen",
            "Abholung bestätigen",
            "Abholcode",
            "Anzeigename",
            "Gib den vierstelligen Abholcode ein. Die abholende Person kennt ihn.",
            "Nenne den Code bei der Übergabe. Damit wird die Abholung bestätigt.",
            "Bestätige mit diesem Code, sobald du den Beutel geholt hast.",
            "Kein Konto, kein Passwort: Dein Name steht nur auf deinen Angeboten und Abholungen auf diesem Gerät. Ein vierstelliger Abholcode bestätigt jede Übergabe.",
            "error.handover_code",
            "claim.success_code",
            "actor.neighbour",
            "account.mode_local",
            "storage.on_device"
        ]
        for language in ["de", "en", "ar", "tr"] {
            guard let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language),
                  let dictionary = NSDictionary(contentsOfFile: path) as? [String: String] else {
                return XCTFail("Missing localisation \(language)")
            }
            required.forEach { XCTAssertNotNil(dictionary[$0], "Missing \($0) in \(language)") }
        }
    }

    func testLegacySafetyCopyNoLongerForbidsHomeCollection() {
        let key = "Wähle einen belebten, gut beleuchteten Ort – nie eine Wohnung."
        for language in ["de", "en", "ar", "tr"] {
            guard let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language),
                  let dictionary = NSDictionary(contentsOfFile: path) as? [String: String],
                  let value = dictionary[key] else {
                return XCTFail("Missing localisation \(language)")
            }
            XCTAssertFalse(value.localizedCaseInsensitiveContains("never a home"))
            XCTAssertFalse(value.localizedCaseInsensitiveContains("nie eine Wohnung"))
            XCTAssertFalse(value.localizedCaseInsensitiveContains("asla ev"))
        }
    }

    func testRuntimeLanguageSwitchChangesDynamicStrings() {
        UserDefaults.standard.set("en", forKey: "appLanguage")
        XCTAssertEqual(OfferStatus.open.title, "Available")
        UserDefaults.standard.set("tr", forKey: "appLanguage")
        XCTAssertEqual(OfferStatus.open.title, "Müsait")
        UserDefaults.standard.set("ar", forKey: "appLanguage")
        XCTAssertEqual(OfferStatus.open.title, "متاح")
        XCTAssertTrue(AppLanguage.ar.isRightToLeft)
        XCTAssertFalse(AppLanguage.de.isRightToLeft)
    }
}
