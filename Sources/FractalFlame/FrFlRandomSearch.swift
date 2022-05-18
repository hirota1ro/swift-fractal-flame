import Cocoa

extension FractalFlame.Search {

    mutating func run() throws {
        let element = try FFElement.readFile(name: inputFile)
        let newParent = FFElement(varias: [], flames: [], children: [])
        let imProgress = MeasurementProgress(IndeterminableProgress())
        let ctProgress = MeasurementProgress(DeterminableProgress())
        randomSearch(parent: newParent, reference: element, imageProgress: imProgress, countProgress: ctProgress)
        let fileURL = URL(fileURLWithPath: outputFile)
        try newParent.writeTo(fileURL: fileURL)
    }

    var sizeOfImage: CGSize { return CGSize(width: width, height: height ?? width) }


    /// Find good images and hang them on parent's children
    /// Use the same variations as reference's them
    /// - Parameters:
    ///   - parent: element to output
    ///   - reference: element to reference
    ///   - imageProgress: progress interface for image
    ///   - countProgress: progress interface for search
    func randomSearch(parent: FFElement, reference: FFElement, imageProgress: FrFlProgress, countProgress: FrFlProgress) {
        let size = sizeOfImage
        let half = size / 2
        let at2 = CGAffineTransform(translationX: half.width, y: half.height)
          .scaledBy(x: half.width, y: half.height)
          .scaledBy(x: CGFloat(scale), y: CGFloat(scale))

        let varias = reference.varias
        var found = 0
        var failed = 0
        var threshold = self.threshold
        countProgress.begin()
        while found < count {
            let flames: [FFFlame] = useBaseElement
              ? randomFlames(base: reference)
              : randomFlames(n: reference.flames.count, m: varias.count)
            let elt = FFElement(varias: varias, flames: flames, children: [])
            let ff = elt.fractalFlame
            let stat = FrFlStatSpan()
            let overflowed = !ff.draw(iterations: iterations, plotter: stat, progress: imageProgress)
            if overflowed {
                print("OVERFLOWED")
                failed += 1
                continue
            }
            let at1: CGAffineTransform = stat.point.transform

            let rndrr = FrFlStatRatio(size: size, transform: at1 * at2)
            let succeeded = ff.draw(iterations: iterations, plotter: rndrr, progress: imageProgress)
            let ratio = rndrr.ratio
            if succeeded && ratio > threshold {
                print("good - \(ratio) > \(threshold)", terminator:"")
                elt.title = fileName(number: found)
                elt.stat = stat.node
                parent.add(child: elt)
                found += 1
                countProgress.progress(Float(found) / Float(count))
                failed = 0
            } else {
                print("bad - \(ratio) < \(threshold)", terminator:"")
                failed += 1
                if failed > concession {
                    failed = 0
                    threshold *= 0.5
                    print(" -> threshold=\(threshold)", terminator:"")
                }
                print("")
            }
        }
        countProgress.end()
    }

    func fileName(number: Int) -> String {
        return String(format: "%04d", number)
    }

    /// create flames randomly
    /// - Parameters:
    ///   - n: the number of F (e.g. 2)
    ///   - m: the number of V (e.g. 1)
    /// - Returns: new flames
    func randomFlames(n: Int, m: Int) -> [FFFlame] {
        let Δc = 1 / Float(n - 1) // Amount of color to change
        let array: [FFFlame] = (0 ..< n).map { i -> FFFlame in
            let ang = Float.random(in: -.pi ..< .pi)
            let rot = FFAffineRotation(rotationAngle: ang)
            let tx = Float.random(in: -1.0 ..< 1.0)
            let ty = Float.random(in: -1.0 ..< 1.0)
            let tr = FFAffineTranslation(translationX: tx, y: ty)
            let scx = Float.random(in: -1.0 ..< 1.0)
            let scy = Float.random(in: -1.0 ..< 1.0)
            let scl = FFAffineScale(scaleX: scx, y: scy)
            let skx = Float.random(in: -1.0 ..< 1.0)
            let sky = Float.random(in: -1.0 ..< 1.0)
            let skw = FFAffineSkew(skewX: skx, y: sky)
            let affine = FFAffineComposite(array: [skw, rot, scl, tr])
            let b1: [Float] = (0 ..< m).map { _ in Float.random(in: 0.0 ..< 1.0) }
            let b2 = b1.reduce(0, +)
            let b3 = b1.map { $0 / b2 }
            let blend = b3
            let color = Float(i) * Δc
            return FFFlame(affine: affine, blend: blend, color: color)
        }
        return array
    }

    /// create flames randomly (referenced base element)
    /// - Parameter base: Starting element
    /// - Returns: new flames
    func randomFlames(base: FFElement) -> [FFFlame] {
        let array: [FFFlame] = base.flames.map { baseFlame in
            let baseAffine = baseFlame.affine.flattend
            let a = baseAffine.a + Float.random(in: -0.1 ..< 0.1)
            let b = baseAffine.b + Float.random(in: -0.1 ..< 0.1)
            let c = baseAffine.c + Float.random(in: -0.1 ..< 0.1)
            let d = baseAffine.d + Float.random(in: -0.1 ..< 0.1)
            let tx = baseAffine.tx + Float.random(in: -0.1 ..< 0.1)
            let ty = baseAffine.ty + Float.random(in: -0.1 ..< 0.1)
            let affine = FFAffineMatrix(a:a, b:b, c:c, d:d, tx:tx, ty:ty)
            let b1: [Float] = baseFlame.blend.map { $0 + Float.random(in: -0.1 ..< 0.1) }
            let blend = b1
            let color = baseFlame.color
            return FFFlame(affine: affine, blend: blend, color: color)
        }
        return array
    }
}
