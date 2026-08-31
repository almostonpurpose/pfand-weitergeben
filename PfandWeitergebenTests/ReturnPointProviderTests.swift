import XCTest
@testable import PfandWeitergeben

final class ReturnPointProviderTests: XCTestCase {
    override func tearDown() {
        UserDefaults.standard.set("de", forKey: "appLanguage")
        super.tearDown()
    }

    func testDemoProviderIsClearlyBoundedSampleData() {
        UserDefaults.standard.set("en", forKey: "appLanguage")
        let provider: any ReturnPointProviding = DemoReturnPointProvider()

        XCTAssertTrue(provider.isSampleData)
        XCTAssertEqual(provider.returnPoints.count, 6)
        XCTAssertEqual(provider.returnPoints.filter { $0.kind == .supermarket }.count, 3)
        XCTAssertEqual(provider.returnPoints.filter { $0.kind == .glassRecycling }.count, 3)
        XCTAssertTrue(provider.attribution.localizedCaseInsensitiveContains("sample"))
        XCTAssertTrue(provider.attribution.localizedCaseInsensitiveContains("no claim"))
    }

    func testDemoCoordinatesAreBerlinSamplesAndLabelsAreLocalised() {
        UserDefaults.standard.set("de", forKey: "appLanguage")
        let points = DemoReturnPointProvider().returnPoints

        for point in points {
            XCTAssertTrue((52.3 ... 52.7).contains(point.latitude))
            XCTAssertTrue((13.1 ... 13.8).contains(point.longitude))
            XCTAssertTrue(point.name.hasPrefix("Beispiel:"))
            XCTAssertFalse(point.area.isEmpty)
        }
    }
}
