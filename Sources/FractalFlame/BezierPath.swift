import Cocoa

struct BezierPath {
    let segments: [Segment]
}

extension BezierPath {
    enum Segment {
        case M(to: CGPoint)
        case L(to: CGPoint)
        case Q(control: CGPoint, to: CGPoint)
        case C(control1: CGPoint, control2: CGPoint, to: CGPoint)
        case Z
    }
}

extension BezierPath {

    var raw: NSBezierPath {
        let path = NSBezierPath()
        for segment in segments {
            switch segment {
            case let .M(p): path.move(to: p)
            case let .L(p): path.line(to: p)
            case let .Q(c, p): path.curve(to: p, controlPoint1: c, controlPoint2: c)
            case let .C(c, d, p): path.curve(to: p, controlPoint1: c, controlPoint2: d)
            case .Z: path.close()
            }
        }
        return path
    }
}
