import Cocoa

extension FractalFlame.Interpolate {

    mutating func run() throws {
        let element = try FFElement.readFile(name: inputFile)
        let parent = FFElement(varias: [], flames: [], children: [])
        let endPoints: [FFElement] = element.children
        guard let first = endPoints.first else { return }
        let varias: [FFVaria] = first.varias

        var prev: FFElement? = nil
        for next in endPoints {
            if let prev = prev {
                interpolate(parent: parent, varias: varias, from: prev, to: next)
            }
            prev = next
        }

        let fileURL = URL(fileURLWithPath: outputFile)
        try parent.writeTo(fileURL: fileURL)
    }

    func interpolate(parent: FFElement, varias: [FFVaria], from: FFElement, to: FFElement) {
        for k in 0 ..< count {
            let t = Float(k) / Float(count)
            let flames: [FFFlame] = interpolateFlames(at: t, from: from.flames, to: to.flames)
            let child = FFElement(varias: varias, flames: flames, children: [])
            child.stat = interpolateStat(at: t, from: from.stat, to: to.stat)
            // if let st = child.stat {
            //     print("stat=\(st)")
            // } else {
            //     print("stat=nil")
            // }
            parent.add(child: child)
        }
    }

    func interpolateFlames(at: Float, from: [FFFlame], to: [FFFlame]) -> [FFFlame] {
        return zip(from, to).map { [self] in
            return interpolateFlame(at: at, start: $0, goal: $1)
        }
    }

    func interpolateFlame(at: Float, start: FFFlame, goal: FFFlame) -> FFFlame {
        let affine = start.affine + at * (goal.affine - start.affine)
        let blend = start.blend + at * (goal.blend - start.blend)
        let color = start.color + at * (goal.color - start.color)
        return FFFlame(affine: affine, blend: blend, color: color)
    }

    func interpolateStat(at: Float, from: FFStat?, to: FFStat?) -> FFStat? {
        guard let start = from else {
            print("from=nil")
            return nil
        }
        guard let goal = to else {
            print("to=nil")
            return nil
        }
        return start + at * (goal - start)
    }
}

extension Array where Element==Float {
    static func + (a: [Float], b: [Float]) -> [Float] {
        return zip(a, b).map { $0.0 + $0.1 }
    }
    static func - (a: [Float], b: [Float]) -> [Float] {
        return zip(a, b).map { $0.0 - $0.1 }
    }
    static func * (s: Float, v: [Float]) -> [Float] {
        return v.map { s * $0 }
    }
}
