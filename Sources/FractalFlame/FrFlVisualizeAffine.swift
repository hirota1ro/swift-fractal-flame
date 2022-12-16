import Cocoa

extension FractalFlame.VisualizeAffine {

    var sizeOfImage: CGSize { return CGSize(width: width, height: height ?? width) }

    mutating func run() throws {
        let resolver = SuffixFilePathResolver(path: outputFile)
        let size = sizeOfImage
        let element = try FFElement.readFile(name: inputFile)
        element.traverse { (elt:FFElement, depth:Int, number:Int) in
            for (i, flame) in elt.flames.enumerated() {
                let image = image(with: flame.affine.cg, size: size)
                let fileURL = resolver.resolve(suffix: "\(depth)-\(number)-\(i)")
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

    func image(with transform: CGAffineTransform, size: CGSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.white.setFill()
        CGRect(origin: .zero, size: size).fill()
        let screen = toScreen
        NSColor.gray.setStroke()
        drawAxis(size: size)
        let path = figure()
        NSColor.blue.setStroke()
        path.applied(screen).stroke()
        path.transform(using: AffineTransform(cgTransform: transform))
        NSColor.red.setStroke()
        path.applied(screen).stroke()
        draw(text: "\(transform)", at: CGPoint(x:0, y: size.height), color: .black)
        image.unlockFocus()
        return image
    }

    private func figure() -> NSBezierPath {
        let segments: [BezierPath.Segment] = [
          .M(to: CGPoint(x: 0.25, y: 1)),
          .L(to: CGPoint(x: 0.25, y: -0.5)),
          .Q(control: CGPoint(x: 0.25, y: -0.75), to: CGPoint(x: 0.5, y: -0.75)),
          .L(to: CGPoint(x: 0.5, y: -1)),
          .L(to: CGPoint(x: -0.5, y: -1)),
          .L(to: CGPoint(x: -0.5, y: -0.75)),
          .Q(control:CGPoint(x: -0.25, y: -0.75), to: CGPoint(x: -0.25, y: -0.5)),
          .L(to: CGPoint(x: -0.25, y: 0.5)),
          .L(to: CGPoint(x: -0.5, y: 0.5)),
          .L(to: CGPoint(x: -0.5, y: 0.75)),
          .Q(control:CGPoint(x: -0.25, y: 0.75), to: CGPoint(x: -0.25, y: 1)),
          .Z
        ]
        return BezierPath(segments: segments).raw
    }

    private func drawAxis(size: CGSize) {
        let logicToScreen = self.toScreen
        let z: CGPoint = .zero.applying(logicToScreen)
        let xAxis = NSBezierPath(lineFrom: CGPoint(x:0, y:z.y), to: CGPoint(x: size.width, y:z.y))
        xAxis.stroke()
        let yAxis = NSBezierPath(lineFrom: CGPoint(x:z.x, y:0), to: CGPoint(x:z.x, y: size.height))
        yAxis.stroke()
    }

    private func draw(text: String, at: CGPoint, color: NSColor) {
        let attr: [NSAttributedString.Key: Any] = [ .foregroundColor: color ]
        text.draw(at: at + CGPoint(x: 4, y: -16), withAttributes: attr)
    }
}
