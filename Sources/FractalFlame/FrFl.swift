import Foundation

struct FrFl {
    let variations: [VF]
    let flames: [F]
}

extension FrFl {

    /// draw algorithm
    ///
    /// - Parameters:
    ///   - iterations: number of iterations
    ///   - plotter: interface to plot point
    ///   - progress: interface to indicate process
    /// - Returns: true if succeeded, otherwize false.
    ///
    func draw(iterations: Int, plotter: FrFlPlotter, progress: FrFlProgress) -> Bool {
        guard flames.count > 0 else { return false }
        var p = CGPoint(x: 0.01, y: 0.01)
        var c = flames[0].c
        var t: Int = 0
        progress.begin()
        defer { progress.end() }
        for k in 0 ..< iterations {
            let i = Int.random(in: 0 ..< flames.count)
            let f = flames[i]
            let prev = p
            p = p.applying(f.a)
            guard p.isValid else { return false }
            p = f.bv.reduce(.zero) { $0 + $1.b * $1.v(p) }
            guard p.isValid else { return false }
            c = (c + f.c) / 2
            if 20 < k {
                plotter.plot(point: p, color: c, velocity: p - prev)
            }
            if t < k {
                progress.progress(Float(k)/Float(iterations))
                t += iterations / 10
            }
        }
        return true
    }
}

extension FrFl: CustomStringConvertible {
    var title: String {
        let t = variations.map({ "\($0)" }).joined(separator: ", ")
        return "V=[\(t)]"
    }
    var description: String {
        var buf: [String] = [ title ]
        buf += flames.enumerated().map { return "F\(Subscript(value: $0.offset)): \($0.element)" }
        return buf.joined(separator: "\n")
    }
}

protocol FrFlPlotter {
    func plot(point: CGPoint, color: CGFloat, velocity: CGPoint)
}

protocol FrFlProgress {
    func begin()
    func progress(_ value: Float)
    func end()
}

extension FrFl {

    struct F {
        let w: CGFloat
        let a: CGAffineTransform
        let bv: [BV]
        let c: CGFloat
    }

    struct BV {
        let b: CGFloat
        let v: V
    }
}

extension FrFl.F: CustomStringConvertible {
    var description: String {
        let sbv = bv.map({ String(format:"%.2f", $0.b) }).joined(separator: ", ")
        return "A={\(a)}, B=[\(sbv)]"
    }
}
