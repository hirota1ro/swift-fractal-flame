import Cocoa

class FrFlStatSpan {
    var point: PointSpan = PointSpan()
    var velocity: Span = Span()
}

extension FrFlStatSpan: FrFlPlotter {
    func plot(point: CGPoint, color: CGFloat, velocity: CGPoint) {
        self.point.update(point: point)
        self.velocity.update(velocity.norm)
    }
}

extension FrFlStatSpan: CustomStringConvertible {
    var description: String {
        return "{StatSpan p=\(point) v=\(velocity)}"
    }
}

extension FrFlStatSpan {
    var isValid: Bool {
        return point.isValid && velocity.isValid
    }

    var node: FFStat {
        return FFStat(x: FFSpan(span: point.x),
                      y: FFSpan(span: point.y),
                      v: FFSpan(span: velocity))
    }
}

// MARK: -

class FrFlStatRatio {
    // parameters to draw
    // let size: CGSize // size of image
    let screen: CGAffineTransform
    let bounds: CGRect
    // work area
    var bm: BitMatrix

    /// - Parameters:
    ///   - size: of image
    ///   - transform: from logical space to screen
    init(size: CGSize, transform: CGAffineTransform) {
        screen = transform
        bounds = CGRect(origin: .zero, size: size)
        bm = BitMatrix(width: Int(size.width), height: Int(size.height))
    }

    var ratio: Float { return bm.bitRatio }
}

extension FrFlStatRatio: FrFlPlotter {
    func plot(point: CGPoint, color: CGFloat, velocity: CGPoint) {
        let p = point.applying(screen)
        if bounds.contains(p) {
            let x = Int(p.x)
            let y = Int(p.y)
            if bm.inside(x: x, y: y) {
                bm[x, y] = 1
            }
        }
    }
}
