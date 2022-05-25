import XCTest
@testable import FractalFlame

class FFNodeTests: XCTestCase {

    func testFFFlame() throws {
        let a1: [String: Any] = [ "angle": 0.1 ]
        let dict: [String: Any] = ["A":a1, "B":[1], "C": 0.5 ]
        let flm = FFFlame.create(fromDict: dict)!
        XCTAssertEqual(flm.color, 0.5)
    }

    func testFFElement() throws {
        let a1: [String: Any] = [ "angle":0.1 ]
        let a2: [String: Any] = [ "sx":2, "sy":2 ]
        let f1: [String: Any] = ["A":a1, "B":[1], "C": 0.1 ]
        let f2: [String: Any] = ["A":a2, "B":[1], "C": 0.9 ]
        let va: Any = ["Spherical"]
        let fa: Any = [f1, f2]
        let dict: [String: Any] = ["V": va, "F": fa ]
        let elt = FFElement.create(fromDict: dict)
        XCTAssertEqual(elt.varias.count, 1)
        XCTAssertEqual(elt.flames.count, 2)
    }
}
