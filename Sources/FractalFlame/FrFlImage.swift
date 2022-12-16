import Cocoa

extension FractalFlame.Image {

    mutating func run() throws {
        let element = try FFElement.readFile(name: inputFile)
        let fpr: FilePathResolver = element.singular != nil ? ConstFilePathResolver(path: outputFile) : SuffixFilePathResolver(path: outputFile)
        element.traverse { (elt:FFElement, idxs: IndexPath) in
            if elt.isValid {
                let at = elt.pointSpan.transform
                let br: FrFlBrightnessResolver = dark ? BlackBackBrightnessResolver() : WhiteBackBrightnessResolver()
                let cr = VelocityColorResolver(velocity: elt.velocitySpan, factor: CGFloat(colorFactor), brightness: br)
                let image = createImage(with: elt.fractalFlame, resolver: cr, transform: at)
                let fileURL = fpr.resolve(suffix: idxs.pathLike)
                image.writeTo(fileURL: fileURL)
            }
        }
    }

    var sizeOfImage: CGSize { return CGSize(width: width, height: height ?? width) }

    func createImage(with ff: FrFl, resolver: FrFlColorResolver, transform: CGAffineTransform) -> NSImage {
        let progress = MeasurementProgress(IndeterminableProgress())
        if density > 1 {
            let small = sizeOfImage
            let large = small * CGFloat(density)
            let n = iterations * density * density
            let screen = transform * createScreenTransform(size: large)
            let renderer = createRasterizer(size: large, screen: screen, resolver: resolver)
            let imgL = renderer.image(with: ff, iterations: n, progress: progress)
            let imgS = imgL.resized(to: small)
            if let image = imgS.gammaAdjusted(inputPower: gamma) {
                return image
            }
            return imgS
        } else {
            let size = sizeOfImage
            let screen = transform * createScreenTransform(size: size)
            let renderer = createRasterizer(size: size, screen: screen, resolver: resolver)
            return renderer.image(with: ff, iterations: iterations, progress: progress)
        }
    }

    func createRasterizer(size: CGSize, screen: CGAffineTransform, resolver: FrFlColorResolver) -> FrFlRasterizer {
        var renderer = FrFlRasterizer(size: size, screen: screen, resolver: resolver)
        if transparent {
            renderer.backgroundColor = nil
        } else {
            if dark {
                renderer.backgroundColor = .black
            } else {
                renderer.backgroundColor = .white
            }
        }
        return renderer
    }

    func createScreenTransform(size: CGSize) -> CGAffineTransform {
        let half = size / 2
        return CGAffineTransform(translationX: half.width, y: half.height)
          .scaledBy(x: half.width, y: half.height)
          .scaledBy(x: CGFloat(scale), y: CGFloat(scale))
          .scaledBy(x: horizontalFlip ? -1 : 1, y: verticalFlip ? -1 : 1)
    }
}

extension IndexPath {

    var pathLike: String {
        let a = self.map { return String(format: "%04d", $0) }
        return a.joined(separator: "-")
    }
}
