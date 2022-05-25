import XCTest
@testable import FractalFlame

class FFAffineTests: XCTestCase {

    func testFFAffine() throws {
        let dict: [String: Any] = ["a":0.70, "b":-0.14, "c":-0.61, "d":-0.05, "tx":0.17, "ty":0.73]
        let affine = FFAffine.create(fromDict: dict)!
        let a1 = CGAffineTransform(a:0.70, b:-0.14, c:-0.61, d:-0.05, tx:0.17, ty:0.73)
        XCTAssertEqual(affine.cg.a, a1.a, accuracy: 1e-5)
    }
}
