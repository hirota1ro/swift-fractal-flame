import Cocoa

extension FractalFlame.VisualizeVariation {

    var sizeOfImage: CGSize { return CGSize(width: width, height: height ?? width) }

    mutating func run() throws {
        let resolver = SuffixFilePathResolver(path: outputFile)
        let size = sizeOfImage
        let element = try FFElement.readFile(name: inputFile)
        let tr = element.flames.first?.affine.cg ?? .identity
        for varia: FFVaria in element.varias {
            if let vf: FrFl.VF = varia.variation {
                let image = image(with: vf, size: size, transform: tr)
                let fileURL = resolver.resolve(suffix: vf.description)
                image.writeTo(fileURL: fileURL)
            }
        }
    }

    var toScreen: CGAffineTransform {
        let size = sizeOfImage
        let half = size / 2
        let scaleToFit = CGSize(width: 1, height: 1).scaleToFit(half)
        return CGAffineTransform(translationX: half.width, y: half.height)
          .scaledBy(x: scaleToFit, y: scaleToFit)
          .scaledBy(x: CGFloat(scale), y: CGFloat(scale))
    }

    func image(with vf: FrFl.VF, size: CGSize, transform: CGAffineTransform) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.white.setFill()
        drawBackground(size: size)
        NSColor.gray.setStroke()
        drawAxis(size: size)
        let v = vf.create(transform: transform)
        if vf.continuous {
            NSColor.black.setStroke()
            drawAsLine(v: v)
        } else {
            NSColor.black.setFill()
            drawAsDots(v: v)
        }
        draw(text: "\(vf)", at: CGPoint(x:0, y: size.height), color: .black)
        image.unlockFocus()
        return image
    }

    func drawAsLine(v: FrFl.V) {
        let logicToScreen = self.toScreen
        for y:CGFloat in stride(from: -1, through: 1, by: 0.1) {
            let pts = stride(from: -1, through: 1, by: 0.01).map { x -> CGPoint in
                return v(CGPoint(x: x, y: y)).applying(logicToScreen)
            }
            let path = NSBezierPath(polylinePoints: pts)
            path.stroke()
        }
        for x:CGFloat in stride(from: -1, through: 1, by: 0.1) {
            let pts = stride(from: -1, through: 1, by: 0.01).map { y -> CGPoint in
                return v(CGPoint(x: x, y: y)).applying(logicToScreen)
            }
            let path = NSBezierPath(polylinePoints: pts)
            path.stroke()
        }
    }

    func drawAsDots(v: FrFl.V) {
        let logicToScreen = self.toScreen
        for y in stride(from: -1, through: 1, by: 0.05) {
            for x in stride(from: -1, through: 1, by: 0.05) {
                let p₁ = CGPoint(x: x, y: y)
                let p₂ = v(p₁)
                let q = p₂.applying(logicToScreen)
                let circle = NSBezierPath(circleCenter: q, radius: 1)
                circle.fill()
            }
        }
    }

    private func drawAxis(size: CGSize) {
        let logicToScreen = self.toScreen
        let min = CGPoint(x: -1, y: -1).applying(logicToScreen)
        let max = CGPoint(x: 1, y: 1).applying(logicToScreen)
        let pts = [CGPoint(x: min.x, y: min.y),
                   CGPoint(x: max.x, y: min.y),
                   CGPoint(x: max.x, y: max.y),
                   CGPoint(x: min.x, y: max.y),]
        let frm = NSBezierPath(polygonPoints: pts)
        frm.stroke()
        let z: CGPoint = .zero.applying(logicToScreen)
        let xAxis = NSBezierPath(lineFrom: CGPoint(x:0, y:z.y), to: CGPoint(x: size.width, y:z.y))
        xAxis.stroke()
        let yAxis = NSBezierPath(lineFrom: CGPoint(x:z.x, y:0), to: CGPoint(x:z.x, y: size.height))
        yAxis.stroke()
    }

    private func drawBackground(size: CGSize) {
        CGRect(origin: .zero, size: size).fill()
    }

    private func draw(text: String, at: CGPoint, color: NSColor) {
        let attr: [NSAttributedString.Key: Any] = [ .foregroundColor: color ]
        text.draw(at: at + CGPoint(x: 4, y: -16), withAttributes: attr)
    }
}
