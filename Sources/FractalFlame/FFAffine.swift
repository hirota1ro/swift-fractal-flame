import Foundation

// abstract class
class FFAffine: FFNode, FFJSONable, FFCSVable {
    var clone: FFAffine { get { fatalError("Not implementation") } }
    var json: Any { get { fatalError("Not implementation") } }
    var csv: [String] { get { fatalError("Not implementation") } }
    var cg: CGAffineTransform { get { fatalError("Not implementation") } }
    var flattend: FFAffineMatrix { get { fatalError("Not implementation") } }
    func accept(visitor: FFAffineVisitor) { fatalError("Not implementation") }
}

// Visitor pattern
protocol FFAffineVisitor {
    func visit(matrix: FFAffineMatrix)
    func visit(rotation: FFAffineRotation)
    func visit(translation: FFAffineTranslation)
    func visit(scale: FFAffineScale)
    func visit(skew: FFAffineSkew)
    func visit(composite: FFAffineComposite)
}

extension FFAffine {
    static func + (a: FFAffine, b: FFAffine) -> FFAffine { return a.flattend + b.flattend }
    static func - (a: FFAffine, b: FFAffine) -> FFAffine { return a.flattend - b.flattend }
    static func * (s: Float, v: FFAffine) -> FFAffine { return s * v.flattend }
}

extension FFAffine {
    static let identity = FFAffineMatrix(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)

    static func create(fromJSON: Any?) -> FFAffine? {
        guard let value = fromJSON else { return nil }
        if let array = value as? [Any] {
            return FFAffineComposite.createComposite(fromArray: array)
        }
        if let dict = value as? [String: Any] {
            return create(fromDict: dict)
        }
        return nil
    }

    static func create(fromDict: [String: Any]) -> FFAffine? {
        if let rot = FFAffineRotation.createRotation(fromDict: fromDict) {
            return rot
        }
        if let tr = FFAffineTranslation.createTranslation(fromDict: fromDict) {
            return tr
        }
        if let scl = FFAffineScale.createScale(fromDict: fromDict) {
            return scl
        }
        if let skw = FFAffineSkew.createSkew(fromDict: fromDict) {
            return skw
        }
        return FFAffineMatrix.createMatrix(fromDict: fromDict)
    }
}

// MARK: - Matrix

class FFAffineMatrix: FFAffine {
    var a: Float
    var b: Float
    var c: Float
    var d: Float
    var tx: Float
    var ty: Float
    init(a: Float, b: Float, c: Float, d: Float, tx: Float, ty: Float) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.tx = tx
        self.ty = ty
    }

    override var clone: FFAffine {
        return FFAffineMatrix(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }

    override var json: Any {
        return [ "a": a, "b": b, "c": c, "d": d, "tx": tx, "ty": ty]
    }

    override var csv: [String] {
        return [ a, b, c, d, tx, ty ].map { "\($0)" }
    }

    override var cg: CGAffineTransform {
        return CGAffineTransform(a: CGFloat(a), b: CGFloat(b), c: CGFloat(c), d: CGFloat(d), tx: CGFloat(tx), ty: CGFloat(ty))
    }

    override var flattend: FFAffineMatrix { return self }

    override func accept(visitor: FFAffineVisitor) { visitor.visit(matrix: self) }
}

extension FFAffineMatrix {
    convenience init(withCGAffineTransform cg: CGAffineTransform) {
        self.init(a: Float(cg.a), b: Float(cg.b), c: Float(cg.c), d: Float(cg.d), tx: Float(cg.tx), ty: Float(cg.ty))
    }
}

extension FFAffineMatrix {
    static func + (a: FFAffineMatrix, b: FFAffineMatrix) -> FFAffineMatrix {
        return FFAffineMatrix(a: a.a+b.a, b: a.b+b.b, c: a.c+b.c, d: a.d+b.d, tx: a.tx+b.tx, ty: a.ty+b.ty)
    }
    static func - (a: FFAffineMatrix, b: FFAffineMatrix) -> FFAffineMatrix {
        return FFAffineMatrix(a: a.a-b.a, b: a.b-b.b, c: a.c-b.c, d: a.d-b.d, tx: a.tx-b.tx, ty: a.ty-b.ty)
    }
    static func * (s: Float, v: FFAffineMatrix) -> FFAffineMatrix {
        return FFAffineMatrix(a: v.a * s, b: v.b * s, c: v.c * s, d: v.d * s, tx: v.tx * s, ty: v.ty * s)
    }
}

extension FFAffineMatrix {

    static func createMatrix(fromDict: [String: Any]) -> FFAffineMatrix? {
        guard fromDict.count == 6 else { return nil }
        guard let a = Float.create(fromJSON: fromDict["a"]) else { return nil }
        guard let b = Float.create(fromJSON: fromDict["b"]) else { return nil }
        guard let c = Float.create(fromJSON: fromDict["c"]) else { return nil }
        guard let d = Float.create(fromJSON: fromDict["d"]) else { return nil }
        guard let tx = Float.create(fromJSON: fromDict["tx"]) else { return nil }
        guard let ty = Float.create(fromJSON: fromDict["ty"]) else { return nil }
        return FFAffineMatrix(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }
}

extension FFAffineMatrix : CustomStringConvertible {
    var description: String {
        return "{AffineMatrix a=\(a), b=\(b), c=\(c), d=\(d), tx=\(tx), ty=\(ty)}"
    }
}

// MARK: - Rotation

class FFAffineRotation: FFAffine {
    var angle: Float
    init(rotationAngle: Float) {
        self.angle = rotationAngle
    }

    override var clone: FFAffine {
        return FFAffineRotation(rotationAngle: angle)
    }

    override var json: Any {
        return [ "angle": angle ]
    }

    override var csv: [String] {
        return [ angle ].map { "\($0)" }
    }

    override var cg: CGAffineTransform {
        return CGAffineTransform(rotationAngle: CGFloat(angle))
    }

    override var flattend: FFAffineMatrix {
        return FFAffineMatrix(a: sin(angle), b: -cos(angle), c: cos(angle), d: sin(angle), tx: 0, ty: 0)
    }

    override func accept(visitor: FFAffineVisitor) { visitor.visit(rotation: self) }
}

extension FFAffineRotation {
    static func + (a: FFAffineRotation, b: FFAffineRotation) -> FFAffineRotation {
        return FFAffineRotation(rotationAngle: a.angle+b.angle)
    }
    static func - (a: FFAffineRotation, b: FFAffineRotation) -> FFAffineRotation {
        return FFAffineRotation(rotationAngle: a.angle-b.angle)
    }
    static func * (s: Float, v: FFAffineRotation) -> FFAffineRotation {
        return FFAffineRotation(rotationAngle: s * v.angle)
    }
}

extension FFAffineRotation {

    static func createRotation(fromDict: [String: Any]) -> FFAffineRotation? {
        guard fromDict.count == 1 else { return nil }
        guard let angle = Float.create(fromJSON: fromDict["angle"]) else { return nil }
        return FFAffineRotation(rotationAngle: angle)
    }
}

extension FFAffineRotation : CustomStringConvertible {
    var description: String {
        return "{AffineRotation angle=\(angle)}"
    }
}

// MARK: - Translation

class FFAffineTranslation: FFAffine {
    var tx: Float
    var ty: Float
    init(translationX tx: Float, y ty: Float) {
        self.tx = tx
        self.ty = ty
    }

    override var clone: FFAffine {
        return FFAffineTranslation(translationX: tx, y: ty)
    }

    override var json: Any {
        return [ "tx": tx, "ty": ty ]
    }

    override var csv: [String] {
        return [ tx, ty ].map { "\($0)" }
    }

    override var cg: CGAffineTransform {
        return CGAffineTransform(translationX: CGFloat(tx), y: CGFloat(ty))
    }

    override var flattend: FFAffineMatrix {
        return FFAffineMatrix(a: 1, b: 0, c: 0, d: 1, tx: tx, ty: ty)
    }

    override func accept(visitor: FFAffineVisitor) { visitor.visit(translation: self) }
}

extension FFAffineTranslation {
    static func + (a: FFAffineTranslation, b: FFAffineTranslation) -> FFAffineTranslation {
        return FFAffineTranslation(translationX: a.tx+b.tx, y: a.ty+b.ty)
    }
    static func - (a: FFAffineTranslation, b: FFAffineTranslation) -> FFAffineTranslation {
        return FFAffineTranslation(translationX: a.tx-b.tx, y: a.ty-b.ty)
    }
    static func * (s: Float, v: FFAffineTranslation) -> FFAffineTranslation {
        return FFAffineTranslation(translationX: s * v.tx, y: s * v.ty)
    }
}

extension FFAffineTranslation {

    static func createTranslation(fromDict: [String: Any]) -> FFAffineTranslation? {
        guard fromDict.count == 2 else { return nil }
        guard let tx = Float.create(fromJSON: fromDict["tx"]) else { return nil }
        guard let ty = Float.create(fromJSON: fromDict["ty"]) else { return nil }
        return FFAffineTranslation(translationX: tx, y: ty)
    }
}

extension FFAffineTranslation : CustomStringConvertible {
    var description: String {
        return "{AffineTranslation tx=\(tx), ty=\(ty)}"
    }
}

// MARK: - Scale

class FFAffineScale: FFAffine {
    var sx: Float
    var sy: Float
    init(scaleX sx: Float, y sy: Float) {
        self.sx = sx
        self.sy = sy
    }

    override var clone: FFAffine {
        return FFAffineScale(scaleX: sx, y: sy)
    }

    override var json: Any {
        return [ "sx": sx, "sy": sy ]
    }

    override var csv: [String] {
        return [ sx, sy ].map { "\($0)" }
    }

    override var cg: CGAffineTransform {
        return CGAffineTransform(scaleX: CGFloat(sx), y: CGFloat(sy))
    }

    override var flattend: FFAffineMatrix {
        return FFAffineMatrix(a: sx, b: 0, c: 0, d: sy, tx: 0, ty: 0)
    }

    override func accept(visitor: FFAffineVisitor) { visitor.visit(scale: self) }
}

extension FFAffineScale {
    static func + (a: FFAffineScale, b: FFAffineScale) -> FFAffineScale {
        return FFAffineScale(scaleX: a.sx+b.sx, y: a.sy+b.sy)
    }
    static func - (a: FFAffineScale, b: FFAffineScale) -> FFAffineScale {
        return FFAffineScale(scaleX: a.sx-b.sx, y: a.sy-b.sy)
    }
    static func * (s: Float, v: FFAffineScale) -> FFAffineScale {
        return FFAffineScale(scaleX: s * v.sx, y: s * v.sy)
    }
}

extension FFAffineScale {

    static func createScale(fromDict: [String: Any]) -> FFAffineScale? {
        guard fromDict.count == 2 else { return nil }
        guard let sx = Float.create(fromJSON: fromDict["sx"]) else { return nil }
        guard let sy = Float.create(fromJSON: fromDict["sy"]) else { return nil }
        return FFAffineScale(scaleX: sx, y: sy)
    }
}

extension FFAffineScale : CustomStringConvertible {
    var description: String {
        return "{AffineScale sx=\(sx), sy=\(sy)}"
    }
}

// MARK: - Skew

class FFAffineSkew: FFAffine {
    var skx: Float
    var sky: Float
    init(skewX skx: Float, y sky: Float) {
        self.skx = skx
        self.sky = sky
    }

    override var clone: FFAffine {
        return FFAffineSkew(skewX: skx, y: sky)
    }

    override var json: Any {
        return [ "skx": skx, "sky": sky ]
    }

    override var csv: [String] {
        return [ skx, sky ].map { "\($0)" }
    }

    override var cg: CGAffineTransform {
        return CGAffineTransform(skewX: CGFloat(skx), y: CGFloat(sky))
    }

    override var flattend: FFAffineMatrix {
        return FFAffineMatrix(a: 1, b: skx, c: sky, d: 1, tx: 0, ty: 0)
    }

    override func accept(visitor: FFAffineVisitor) { visitor.visit(skew: self) }
}

extension FFAffineSkew {
    static func + (a: FFAffineSkew, b: FFAffineSkew) -> FFAffineSkew {
        return FFAffineSkew(skewX: a.skx+b.skx, y: a.sky+b.sky)
    }
    static func - (a: FFAffineSkew, b: FFAffineSkew) -> FFAffineSkew {
        return FFAffineSkew(skewX: a.skx-b.skx, y: a.sky-b.sky)
    }
    static func * (s: Float, v: FFAffineSkew) -> FFAffineSkew {
        return FFAffineSkew(skewX: s * v.skx, y: s * v.sky)
    }
}

extension FFAffineSkew {

    static func createSkew(fromDict: [String: Any]) -> FFAffineSkew? {
        guard fromDict.count == 2 else { return nil }
        guard let skx = Float.create(fromJSON: fromDict["skx"]) else { return nil }
        guard let sky = Float.create(fromJSON: fromDict["sky"]) else { return nil }
        return FFAffineSkew(skewX: skx, y: sky)
    }
}

extension FFAffineSkew : CustomStringConvertible {
    var description: String {
        return "{AffineSkew skx=\(skx), sky=\(sky)}"
    }
}

// MARK: - Composite

class FFAffineComposite: FFAffine {
    var array: [FFAffine]

    init(array: [FFAffine]) {
        self.array = array
    }

    override var clone: FFAffine {
        return FFAffineComposite(array: array)
    }

    override var json: Any {
        return array.map { $0.json }
    }

    override var csv: [String] {
        return flattend.csv
    }

    override var cg: CGAffineTransform {
        return array.map({ $0.cg }).reduce(.identity, *)
    }

    override var flattend: FFAffineMatrix {
        return FFAffineMatrix(withCGAffineTransform: cg)
    }

    override func accept(visitor: FFAffineVisitor) { visitor.visit(composite: self) }
}

extension FFAffineComposite {
    static func + (a: FFAffineComposite, b: FFAffineComposite) -> FFAffineComposite {
        return FFAffineComposite(array: [ a.flattend + b.flattend ])
    }
    static func - (a: FFAffineComposite, b: FFAffineComposite) -> FFAffineComposite {
        return FFAffineComposite(array: [ a.flattend - b.flattend ])
    }
    static func * (s: Float, v: FFAffineComposite) -> FFAffineComposite {
        return FFAffineComposite(array: [ s * v.flattend ])
    }
}

extension FFAffineComposite {

    static func createComposite(fromArray: [Any]) -> FFAffineComposite? {
        let array: [FFAffine] = fromArray.compactMap { FFAffine.create(fromJSON: $0) }
        return FFAffineComposite(array: array)
    }
}

extension FFAffineComposite : CustomStringConvertible {
    var description: String {
        return "{AffineComposite array=\(array)}"
    }
}
