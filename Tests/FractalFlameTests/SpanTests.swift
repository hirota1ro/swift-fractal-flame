import XCTest
@testable import FractalFlame

class SpanTests: XCTestCase {

    func testSpan() throws {
        let s01 = Span(min: 10, max: 20)
        XCTAssertEqual(s01.normalized(15), 0.5, accuracy: 1e-5)

        var vs = Span()
        vs.update(0.5)
        vs.update(0.1)
        vs.update(0.9)
        XCTAssertEqual(vs.min, 0.1, accuracy: 1e-5)
        XCTAssertEqual(vs.max, 0.9, accuracy: 1e-5)
    }

    func testPointSpan() throws {
        let ps = PointSpan(x: Span(min: 10, max: 20), y: Span(min: 30, max: 40))
        XCTAssertEqual(ps.size, CGSize(width: 10, height: 10))
        XCTAssertEqual(ps.center, CGPoint(x: 15, y: 35))

        var vps = PointSpan()
        vps.update(point: CGPoint(x: -1.0, y: 0.4))
        vps.update(point: CGPoint(x: 0.2, y: 1.0))
        vps.update(point: CGPoint(x: 0.5, y: -1.0))
        vps.update(point: CGPoint(x: 1.0, y: 0.5))
        XCTAssertEqual(vps.x.min, -1.0, accuracy: 1e-5)
        XCTAssertEqual(vps.x.max, 1.0, accuracy: 1e-5)
        XCTAssertEqual(vps.y.min, -1.0, accuracy: 1e-5)
        XCTAssertEqual(vps.y.max, 1.0, accuracy: 1e-5)
    }
}
