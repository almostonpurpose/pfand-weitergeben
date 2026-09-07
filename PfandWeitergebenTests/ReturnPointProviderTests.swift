import XCTest
@testable import PfandWeitergeben

final class ReturnPointProviderTests: XCTestCase {
    override func tearDown() {
        UserDefaults.standard.set("de", forKey: "appLanguage")
        super.tearDown()
    }

    func testBundledProviderLoadsAttributedBerlinOpenDataSnapshot() {
        UserDefaults.standard.set("en", forKey: "appLanguage")
        let provider: any ReturnPointProviding = BundledBerlinReturnPointProvider()

        XCTAssertFalse(provider.isSampleData)
        XCTAssertEqual(provider.returnPoints.count, 177)
        XCTAssertEqual(provider.returnPoints.filter { $0.kind == .supermarket }.count, 92)
        XCTAssertEqual(provider.returnPoints.filter { $0.kind == .glassRecycling }.count, 85)
        XCTAssertEqual(provider.returnPoints.filter { $0.evidence == .bottleReturnMachine }.count, 16)
        XCTAssertTrue(provider.attribution.localizedCaseInsensitiveContains("OpenStreetMap"))
        XCTAssertTrue(provider.attribution.localizedCaseInsensitiveContains("ODbL"))
        XCTAssertNotNil(provider.sourceURL)
    }

    func testBundledCoordinatesCoverBerlinAndHaveUsableLabels() {
        UserDefaults.standard.set("de", forKey: "appLanguage")
        let points = BundledBerlinReturnPointProvider().returnPoints

        XCTAssertFalse(points.isEmpty)
        for point in points {
            XCTAssertTrue((52.3 ... 52.7).contains(point.latitude))
            XCTAssertTrue((13.0 ... 13.9).contains(point.longitude))
            XCTAssertFalse(point.displayName.isEmpty)
            XCTAssertFalse(point.displayArea.isEmpty)
            XCTAssertFalse(point.evidence.note.isEmpty)
        }
    }
}
