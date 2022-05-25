import XCTest
@testable import FractalFlame

class BezierPathTests: XCTestCase {

    func testBezierPath() throws {
        let bp = BezierPath(segments: [
                              .M(to: CGPoint(x: 0, y: 0)),
                              .L(to: CGPoint(x: 1, y: 1)),
                              .Q(control: CGPoint(x: 2, y: 1), to: CGPoint(x: 2, y: 2)),
                              .C(control1: CGPoint(x: 3, y: 2), control2: CGPoint(x: 3, y: 3), to: CGPoint(x: 4, y: 4)),
                              .Z ])
        let ns = bp.raw
        XCTAssertFalse(ns.isEmpty)
    }
}
