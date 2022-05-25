import XCTest
@testable import FractalFlame

class FrFlVariationFactoryTests: XCTestCase {

    func testFrFlVariationFactory() throws {
        let vf = FrFl.obtain(name: "Linear", param: [:])!
        XCTAssertTrue(vf.continuous)
        let v = vf.create(transform: .identity)
        let p100 = CGPoint(x: 100, y: 100)
        let p = v(p100)
        XCTAssertEqual(p, p100)
    }
}
