import Cocoa

extension FractalFlame.Image {

    mutating func run() throws {
        let element = try FFElement.readFile(name: inputFile)
        if let elt = element.singular {
            let at = elt.pointSpan.transform
            let cr = VelocityColorResolver(velocity: elt.velocitySpan, factor: CGFloat(colorFactor))
            let image = createImage(with: elt.fractalFlame, resolver: cr, transform: at)
            let fileURL = URL(fileURLWithPath: outputFile)
            image.writeTo(fileURL: fileURL)
        } else {
            let resolver = FilePathResolver(path: outputFile)
            element.traverse { (elt:FFElement, depth:Int, number:Int) in
                if elt.isValid {
                    let at = elt.pointSpan.transform
                    let cr = VelocityColorResolver(velocity: elt.velocitySpan, factor: CGFloat(colorFactor))
                    let image = createImage(with: elt.fractalFlame, resolver: cr, transform: at)
                    let suffix = suffix(depth: depth, number: number)
                    let fileURL = resolver.resolve(suffix: suffix)
                    image.writeTo(fileURL: fileURL)
                }
            }
        }
    }

    func suffix(depth: Int, number: Int) -> String {
        let d = String(format: "%04d", depth)
        let n = String(format: "%04d", number)
        return "\(d)-\(n)"
    }

    var sizeOfImage: CGSize { return CGSize(width: width, height: height ?? width) }

    func createImage(with ff: FrFl, resolver: FrFlColorResolver, transform: CGAffineTransform) -> NSImage {
        let progress = MeasurementProgress(IndeterminableProgress())
        if density > 1 {
            let small = sizeOfImage
            let large = small * CGFloat(density)
            let n = iterations * density * density
            let screen = transform * createScreenTransform(size: large)
            let renderer = FrFlRasterizer(size: large, screen: screen, resolver: resolver)
            let imgL = renderer.image(with: ff, iterations: n, progress: progress)
            let imgS = imgL.resized(to: small)
            if let image = imgS.gammaAdjusted(inputPower: gamma) {
                return image
            }
            return imgS
        } else {
            let size = sizeOfImage
            let screen = transform * createScreenTransform(size: size)
            let renderer = FrFlRasterizer(size: size, screen: screen, resolver: resolver)
            return renderer.image(with: ff, iterations: iterations, progress: progress)
        }
    }

    func createScreenTransform(size: CGSize) -> CGAffineTransform {
        let half = size / 2
        return CGAffineTransform(translationX: half.width, y: half.height)
          .scaledBy(x: half.width, y: half.height)
          .scaledBy(x: CGFloat(scale), y: CGFloat(scale))
          .scaledBy(x: horizontalFlip ? -1 : 1, y: verticalFlip ? -1 : 1)
    }
}
