import XCTest
@testable import FractalFlame

class FrFlStatisticsTests: XCTestCase {

    func testFrFlStatSpan() throws {
        let ss = FrFlStatSpan()
        ss.plot(point: CGPoint(x: 1, y: 1), color: 0, velocity: CGPoint(x: 1, y: 1))
        ss.plot(point: CGPoint(x: -1, y: 1), color: 0, velocity: CGPoint(x: 0, y: 1))
        ss.plot(point: CGPoint(x: 1, y: -1), color: 0, velocity: CGPoint(x: 1, y: 0))
        ss.plot(point: CGPoint(x: -1, y: -1), color: 0, velocity: CGPoint(x: 0, y: 0))
        XCTAssertTrue(ss.isValid)
        XCTAssertEqual(ss.velocity.min, 0, accuracy: 1e-5)
        XCTAssertEqual(ss.velocity.max, sqrt(2), accuracy: 1e-5)
    }

    func testFrFlStatRatio() throws {
        let sr = FrFlStatRatio(size: CGSize(width: 10, height: 10), transform: .identity)
        sr.plot(point: CGPoint(x: 1, y: 1), color: 0, velocity: .zero)
        sr.plot(point: CGPoint(x: 2, y: 2), color: 0, velocity: .zero)
        sr.plot(point: CGPoint(x: 3, y: 3), color: 0, velocity: .zero)
        sr.plot(point: CGPoint(x: 4, y: 4), color: 0, velocity: .zero)
        XCTAssertEqual(sr.ratio, 0.04, accuracy: 1e-5)
    }
}
