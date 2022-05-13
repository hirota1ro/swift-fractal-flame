import Cocoa

extension NSBezierPath {

    convenience init(lineFrom from: CGPoint, to: CGPoint) {
        self.init()
        move(to: from)
        line(to: to)
    }

    convenience init(polygonPoints points: [CGPoint]) {
        self.init()
        for p in points {
            if isEmpty {
                move(to: p)
            } else {
                line(to: p)
            }
        }
        close()
    }

    convenience init(polylinePoints points: [CGPoint]) {
        self.init()
        for p in points {
            if isEmpty {
                move(to: p)
            } else {
                line(to: p)
            }
        }
    }

    convenience init(circleCenter c: CGPoint, radius r: CGFloat) {
        self.init(ovalIn: CGRect(origin: c - CGPoint(x:r,y:r), size: CGSize(width:2*r, height:2*r)))
    }
}

extension NSBezierPath {

    func applied(_ at: CGAffineTransform) -> NSBezierPath {
        let path = NSBezierPath()
        path.append(self)
        path.transform(using: AffineTransform(cgTransform: at))
        return path.flattened
    }
}

extension AffineTransform {

    /// Create Affine-Transform (AppKit) from Affine-Transform (Core Graphics)
    init(cgTransform at: CGAffineTransform) {
        self.init(m11: at.a, m12: at.b, m21: at.c, m22: at.d, tX: at.tx, tY: at.ty)
    }
}
