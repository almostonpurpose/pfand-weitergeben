import XCTest
import UIKit
@testable import PfandWeitergeben

final class PhotoEstimateTests: XCTestCase {
    func testUnavailableImageFallsBackToEditableCount() {
        let result = PhotoEstimateService.estimate(from: UIImage(), fallback: 14)
        XCTAssertEqual(result, PhotoEstimateResult(count: 14, usedFallback: true))
    }

    func testFallbackNeverCreatesZeroBottleOffer() {
        let result = PhotoEstimateService.estimate(from: UIImage(), fallback: 0)
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(result.usedFallback)
    }

    func testFallbackStaysInsideEditableOfferRange() {
        let result = PhotoEstimateService.estimate(from: UIImage(), fallback: 500)
        XCTAssertEqual(result.count, 200)
        XCTAssertTrue(result.usedFallback)
    }
}
