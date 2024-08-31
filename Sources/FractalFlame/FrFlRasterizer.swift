import Cocoa

struct FrFlRasterizer {

    let size: CGSize // size of image
    let screen: CGAffineTransform // transform from logical space to screen space
    let bounds: CGRect
    let resolver: FrFlColorResolver

    var backgroundColor: NSColor? = .black
    var textColor: NSColor? = nil
}

extension FrFlRasterizer {
    init(size: CGSize, screen: CGAffineTransform, resolver: FrFlColorResolver) {
        self.size = size
        self.screen = screen
        self.bounds = CGRect(origin: .zero, size: size)
        self.resolver = resolver
    }
}

extension FrFlRasterizer {

    /// Create image with given fractal-flame parameters.
    /// - Parameters:
    ///   - ff: fractal flame parameters
    ///   - iterations: the number of iterations (e.g. 100_000 〜 1_000_000)
    ///   - progress: progress interface
    /// - Returuns: new image
    func image(with ff: FrFl, iterations: Int, progress: FrFlProgress) -> NSImage {
        let bm = Bitmap(size: size)
        let cgImg = bm.image { _ in
            if let backgroundColor = backgroundColor {
                backgroundColor.setFill()
                CGRect(origin: .zero, size: size).fill()
            }
            if let textColor = textColor {
                let text = ff.description
                let attr: [NSAttributedString.Key: Any] = [ .foregroundColor: textColor ]
                let h = CGFloat(ff.flames.count + 1) * 14
                text.draw(at: CGPoint(x: 4, y: size.height-h), withAttributes: attr)
            }
            let _ = ff.draw(iterations: iterations, plotter: self, progress: progress)
        }
        return NSImage(cgImage: cgImg, size: size)
    }
}

extension FrFlRasterizer: FrFlPlotter {
    func plot(point: CGPoint, color: CGFloat, velocity: CGPoint) {
        let p = point.applying(screen)
        if bounds.contains(p) {
            resolver.resolve(color: color, velocity: velocity).setFill()
            CGRect(origin: p, size: CGSize(width: 1, height: 1)).fill()
        }
    }
}

protocol FrFlColorResolver {
    func resolve(color: CGFloat, velocity: CGPoint) -> NSColor
}

struct VelocityColorResolver: FrFlColorResolver {
    let velocity: Span
    let factor: CGFloat
    let brightness: FrFlBrightnessResolver
    let alpha: CGFloat = 1.0

    func resolve(color: CGFloat, velocity v: CGPoint) -> NSColor {
        let sat = (velocity.normalized(v.norm) * factor).clamped(to: 0.0 ... 1.0)
        let hue = color - floor(color)
        let bri = brightness.resolve(hue: hue, saturation: sat)
        return NSColor(hue: hue, saturation: sat, brightness: bri, alpha: alpha)
    }
}

protocol FrFlBrightnessResolver {
    func resolve(hue: CGFloat, saturation sat: CGFloat) -> CGFloat
}
struct WhiteBackBrightnessResolver: FrFlBrightnessResolver {
    func resolve(hue: CGFloat, saturation sat: CGFloat) -> CGFloat {
        return sat
    }
}
struct BlackBackBrightnessResolver: FrFlBrightnessResolver {
    func resolve(hue: CGFloat, saturation sat: CGFloat) -> CGFloat {
        return 1
    }
}


extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
