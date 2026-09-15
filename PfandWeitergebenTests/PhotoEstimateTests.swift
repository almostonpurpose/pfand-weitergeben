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

    // A single can with a printed label, a highlight and a shadow must count as one container,
    // not as one container per visible contour.
    func testSingleCanWithLabelAndShadowCountsOnce() {
        let image = TestImages.cans(count: 1)
        let result = PhotoEstimateService.estimate(from: image, fallback: 12)
        XCTAssertFalse(result.usedFallback)
        XCTAssertEqual(result.count, 1)
    }

    func testThreeSeparateCansCountThree() {
        let image = TestImages.cans(count: 3)
        let result = PhotoEstimateService.estimate(from: image, fallback: 12)
        XCTAssertFalse(result.usedFallback)
        XCTAssertEqual(result.count, 3)
    }

    // One can shot up close fills most of the frame. That is the everyday case and must not
    // fall through to the fallback because the silhouette is "too wide".
    func testCloseUpSingleCanCountsOnce() {
        let image = TestImages.closeUpCan()
        let result = PhotoEstimateService.estimate(from: image, fallback: 12)
        XCTAssertFalse(result.usedFallback)
        XCTAssertEqual(result.count, 1)
    }

    // Camera photos arrive with a rotated pixel buffer plus an orientation flag. The estimate
    // has to respect that flag or every upright can looks like a lying one.
    func testRotatedCameraPhotoStillCountsOneCan() {
        let upright = TestImages.cans(count: 1)
        let rotated = TestImages.rotatedForCamera(upright)
        XCTAssertEqual(rotated.imageOrientation, .right)
        let result = PhotoEstimateService.estimate(from: rotated, fallback: 12)
        XCTAssertFalse(result.usedFallback)
        XCTAssertEqual(result.count, 1)
    }
}

enum TestImages {
    static let frame = CGSize(width: 900, height: 1200)

    /// Draws `count` upright cans on a light table. Each can carries a darker label band,
    /// a bright highlight stripe, printed text and a soft shadow, mimicking the nested contours
    /// a real photo produces.
    static func cans(count: Int, canSize: CGSize = CGSize(width: 150, height: 420)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: frame)
        return renderer.image { context in
            let ctx = context.cgContext
            ctx.setFillColor(UIColor(white: 0.96, alpha: 1).cgColor)
            ctx.fill(CGRect(origin: .zero, size: frame))

            let gap: CGFloat = 90
            let totalWidth = CGFloat(count) * canSize.width + CGFloat(count - 1) * gap
            var x = (frame.width - totalWidth) / 2
            let y = (frame.height - canSize.height) / 2

            for _ in 0..<count {
                drawCan(in: CGRect(x: x, y: y, width: canSize.width, height: canSize.height), ctx: ctx)
                x += canSize.width + gap
            }
        }
    }

    /// A single can filling roughly two thirds of the frame width.
    static func closeUpCan() -> UIImage {
        cans(count: 1, canSize: CGSize(width: 560, height: 1050))
    }

    private static func drawCan(in body: CGRect, ctx: CGContext) {
        let w = body.width, h = body.height

        // Shadow to the right, partially overlapping the can.
        ctx.setFillColor(UIColor(white: 0.72, alpha: 1).cgColor)
        ctx.fillEllipse(in: CGRect(x: body.maxX - w * 0.2, y: body.minY + h * 0.28, width: w * 0.53, height: h * 0.71))

        // Can body.
        ctx.setFillColor(UIColor(red: 0.18, green: 0.35, blue: 0.62, alpha: 1).cgColor)
        ctx.addPath(UIBezierPath(roundedRect: body, cornerRadius: w * 0.27).cgPath)
        ctx.fillPath()

        // Label band.
        ctx.setFillColor(UIColor(red: 0.85, green: 0.2, blue: 0.2, alpha: 1).cgColor)
        ctx.fill(CGRect(x: body.minX + w * 0.17, y: body.minY + h * 0.21, width: w * 0.67, height: h * 0.57))

        // Printed text lines on the label.
        ctx.setFillColor(UIColor.white.cgColor)
        for line in 0..<4 {
            ctx.fill(CGRect(x: body.minX + w * 0.3, y: body.minY + h * 0.29 + CGFloat(line) * h * 0.095, width: w * 0.4, height: h * 0.033))
        }

        // Highlight stripe.
        ctx.setFillColor(UIColor(white: 0.92, alpha: 1).cgColor)
        ctx.fill(CGRect(x: body.minX + w * 0.07, y: body.minY + h * 0.05, width: w * 0.23, height: h * 0.9))
    }

    /// Re-encodes `image` the way the camera delivers a portrait shot: the pixel buffer is
    /// rotated 90° and the orientation flag tells consumers to rotate it back.
    static func rotatedForCamera(_ image: UIImage) -> UIImage {
        let landscape = CGSize(width: image.size.height, height: image.size.width)
        let renderer = UIGraphicsImageRenderer(size: landscape)
        let rotated = renderer.image { context in
            let ctx = context.cgContext
            ctx.translateBy(x: landscape.width, y: 0)
            ctx.rotate(by: .pi / 2)
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        guard let cg = rotated.cgImage else { return image }
        return UIImage(cgImage: cg, scale: 1, orientation: .right)
    }
}
