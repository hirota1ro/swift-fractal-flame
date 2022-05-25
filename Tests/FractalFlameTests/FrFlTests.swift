import XCTest
@testable import FractalFlame

class FrFlTests: XCTestCase {

    func testFrFl() throws {
        let a1 = CGAffineTransform(a:0.70, b:-0.14, c:-0.61, d:-0.05, tx:0.17, ty:0.73)
        let a2 = CGAffineTransform(a:-0.58, b:0.25, c:-0.38, d:-0.08, tx:-0.29, ty:0.40)
        let vf = FrFl.Spherical()
        let ff = FrFl(variations: [vf],
                      flames: [
                        FrFl.F(w: 1, a: a1, bv: [FrFl.BV(b:1, v:vf.create(transform: a1))], c: 0),
                        FrFl.F(w: 1, a: a2, bv: [FrFl.BV(b:1, v:vf.create(transform: a2))], c: 0),
                      ])

        let tbr = CGAffineTransform(scaleX: 50, y: 50).translatedBy(x: 50, y: 50)
        let br = FrFlStatRatio(size: CGSize(width: 100, height: 100), transform: tbr)
        XCTAssertTrue(ff.draw(iterations: 100, plotter: br, progress: EmptyProgress()))
    }
}
