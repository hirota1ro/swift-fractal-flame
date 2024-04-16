import Cocoa

extension FractalFlame.Rotate {

    mutating func run() throws {
        let element = try FFElement.readFile(name: inputFile)
        let parent = FFElement(varias: [], flames: [], children: [])
        rotate(parent: parent, element: element)
        let fileURL = URL(fileURLWithPath: outputFile)
        try parent.writeTo(fileURL: fileURL)
    }

    func rotate(parent: FFElement, element: FFElement) {
        let delta = (2 * Float.pi) / Float(count)
        for i in 0 ..< count {
            let child = rotated(element: element, delta: delta * Float(i))
            child.stat = element.stat
            parent.add(child: child)
        }
    }

    func rotated(element: FFElement, delta: Float) -> FFElement {
        let frames: [FFFlame] = element.flames.map { return rotated(flame: $0, delta: delta) }
        return FFElement(varias: element.varias, flames: frames, children: element.children)
    }

    func rotated(flame: FFFlame, delta: Float) -> FFFlame {
        let affine = rotated(affine: flame.affine, delta: delta)
        return FFFlame(affine: affine, blend: flame.blend, color: flame.color)
    }

    func rotated(affine: FFAffine, delta: Float) -> FFAffine {
        let visitor = RotateVisitor(delta: delta)
        affine.accept(visitor: visitor)
        return visitor.result!
    }

    class RotateVisitor: FFAffineVisitor {
        var result: FFAffine? = nil
        let delta: Float
        init(delta: Float) { self.delta = delta }

        func visit(matrix: FFAffineMatrix) { result = matrix }
        func visit(rotation: FFAffineRotation) {
            result = FFAffineRotation(rotationAngle: rotation.angle + delta)
        }
        func visit(translation: FFAffineTranslation) { result = translation }
        func visit(scale: FFAffineScale) { result = scale }
        func visit(skew: FFAffineSkew) { result = skew }
        func visit(composite: FFAffineComposite) { 
            let array: [FFAffine] = composite.array.map { a -> FFAffine in
                let v = RotateVisitor(delta: delta)
                a.accept(visitor: v)
                return v.result!
            }
            result = FFAffineComposite(array: array)
        }
    }
}
