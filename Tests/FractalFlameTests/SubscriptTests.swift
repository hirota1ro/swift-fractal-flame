import XCTest
@testable import FractalFlame

class SubscriptTests: XCTestCase {

    func testSubscript() throws {
        let p123 = Subscript(value: 123)
        XCTAssertEqual(p123.description, "₁₂₃")
        let m10 = Subscript(value: -10)
        XCTAssertEqual(m10.description, "₋₁₀")
    }
}
