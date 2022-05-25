import XCTest
@testable import FractalFlame

class FFVariaTests: XCTestCase {

    func testFFVaria() throws {
        let varia = FFVaria.create(fromDict: ["name":"Linear"])!
        let vf = varia.variation!
        let v = vf.create(transform: .identity)
        XCTAssertEqual(v(.zero), .zero)
    }
}
