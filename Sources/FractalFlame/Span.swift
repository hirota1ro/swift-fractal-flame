import Foundation

struct Span {
    var min: CGFloat
    var max: CGFloat
}

extension Span {
    init() {
        min = .greatestFiniteMagnitude
        max = -.greatestFiniteMagnitude
    }

    mutating func update(_ value: CGFloat) {
        min = Swift.min(min, value)
        max = Swift.max(max, value)
    }

    var isValid: Bool {
        return min.isValid && max.isValid && min < max
    }
    var value: CGFloat { return max - min }
    var center: CGFloat { return (max + min) / 2 }
    func normalized(_ value: CGFloat) -> CGFloat { return (value - min) / (max - min) }
}

extension Span: CustomStringConvertible {
    var description: String { return "{min=\(min) max=\(max)}" }
}

// MARK: -

struct PointSpan {
    var x: Span
    var y: Span
}

extension PointSpan {
    init() {
        x = Span()
        y = Span()
    }

    mutating func update(point: CGPoint) {
        x.update(point.x)
        y.update(point.y)
    }
    var size: CGSize { return CGSize(width: x.value, height: y.value) }
    var center: CGPoint { return CGPoint(x: x.center, y: y.center) }

    var transform: CGAffineTransform {
        let tr = -center
        let scale = size.scaleToFit(CGSize(width: 2, height: 2))
        return CGAffineTransform(scaleX: scale, y: scale)
          .translatedBy(x: tr.x, y: tr.y)
    }

    var isValid: Bool {
        return x.isValid && y.isValid
    }
}

extension PointSpan: CustomStringConvertible {
    var description: String { return "{x=\(x) y=\(y)}" }
}
