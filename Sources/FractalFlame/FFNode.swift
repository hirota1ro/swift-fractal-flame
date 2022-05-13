import Foundation

class FFNode {
}

class FFElement: FFNode {
    var varias: [FFVaria]
    var flames: [FFFlame]
    var children: [FFElement]
    var title: String? = nil
    var stat: FFStat? = nil
    init(varias: [FFVaria], flames: [FFFlame], children: [FFElement]) {
        self.varias = varias
        self.flames = flames
        self.children = children
        super.init()
    }
    func add(child: FFElement) { children.append(child) }
    func remove(child: FFElement) { children.removeAll { $0 === child } }
}

class FFFlame: FFNode {
    var affine: FFAffine
    var blend: [Float]
    var color: Float
    init(affine: FFAffine, blend: [Float], color: Float) {
        self.affine = affine
        self.blend = blend
        self.color = color
        super.init()
    }
}

class FFStat: FFNode {
    var v: FFSpan
    var x: FFSpan
    var y: FFSpan

    init(x: FFSpan, y: FFSpan, v: FFSpan) {
        self.x = x
        self.y = y
        self.v = v
    }
}

extension FFStat {
    static func + (a: FFStat, b: FFStat) -> FFStat { return FFStat(x:a.x+b.x, y:a.y+b.y, v:a.v+b.v) }
    static func - (a: FFStat, b: FFStat) -> FFStat { return FFStat(x:a.x-b.x, y:a.y-b.y, v:a.v-b.v) }
    static func * (s: Float, v: FFStat) -> FFStat { return FFStat(x:s*v.x, y:s*v.y, v:s*v.v) }
}

class FFSpan: FFNode {
    var min: Float
    var max: Float

    init(min: Float, max: Float) {
        self.min = min
        self.max = max
    }
    init(span: Span) {
        self.min = Float(span.min)
        self.max = Float(span.max)
    }
    var value: Float { return max - min }
    var center: Float { return (max + min) / 2 }
    var span: Span { return Span(min: CGFloat(min), max: CGFloat(max)) }
}

extension FFSpan {
    static func + (a: FFSpan, b: FFSpan) -> FFSpan { return FFSpan(min:a.min+b.min, max:a.max+b.max) }
    static func - (a: FFSpan, b: FFSpan) -> FFSpan { return FFSpan(min:a.min-b.min, max:a.max-b.max) }
    static func * (s: Float, v: FFSpan) -> FFSpan { return FFSpan(min:s*v.min, max:s*v.max) }
}

extension FFElement {
    var isInvalid: Bool { return flames.isEmpty }
    var isValid: Bool { return !isInvalid }
    var fractalFlame: FrFl {
        let vars: [FrFl.VF] = varias.compactMap { $0.variation }
        let n = flames.count
        let flms: [FrFl.F] = flames.enumerated().map { $0.element.flame(i: $0.offset, n:n, vars: vars) }
        return FrFl(variations: vars, flames: flms)
    }
    func traverse(_ callback: FFElementCallback) {
        FFElement.traverse(element: self, depth: 0, number: 0, callback)
    }
    static func traverse(element: FFElement, depth: Int, number: Int, _ callback: FFElementCallback) {
        callback(element, depth, number)
        var number: Int = 0
        for child in element.children {
            traverse(element: child, depth: depth + 1, number: number, callback)
            number += 1
        }
    }

    var singular: FFElement? {
        var found: FFElement? = nil
        var dup: Bool = false

        self.traverse { (elt:FFElement, d:Int, n:Int) in
            if elt.isValid {
                if let _ = found {
                    dup = true
                } else {
                    found = elt
                }
            }
        }
        return dup ? nil : found
    }

    var pointSpan: PointSpan {
        let xspan = stat?.x.span ?? Span(min: -1, max: 1)
        let yspan = stat?.y.span ?? Span(min: -1, max: 1)
        return PointSpan(x: xspan, y: yspan)
    }

    var velocitySpan: Span {
        return stat?.v.span ?? Span(min: 0, max: 1)
    }
}

typealias FFElementCallback = (FFElement, Int, Int) -> Void

extension FFFlame {
    func flame(i: Int, n: Int, vars: [FrFl.VF]) -> FrFl.F {
        let a = affine.cg
        let v: [FrFl.V] = vars.map { $0.create(transform: a) }
        let b: [Float] = blend
        let bv: [FrFl.BV] = zip(b, v).map { return FrFl.BV(b: CGFloat($0), v:$1) }
        let c = CGFloat(color)
        return FrFl.F(w: 1, a: a, bv: bv, c: c)
    }
}

extension FFElement {
    var clone: FFElement {
        return FFElement(varias: varias, flames: flames, children: children)
    }
}

extension FFFlame {
    var clone: FFFlame {
        return FFFlame(affine: affine.clone, blend: blend, color: color)
    }
}

protocol FFJSONable {
    var json: Any { get }
}

extension FFElement: FFJSONable {
    var json: Any {
        var dict: [String: Any] = [:]
        if !varias.isEmpty {
            dict["V"] = varias.json
        }
        if !flames.isEmpty {
            dict["F"] = flames.json
        }
        if !children.isEmpty {
            dict["children"] = children.json
        }
        if let t = title {
            dict["title"] = t
        }
        if let s = stat {
            dict["stat"] = s.json
        }
        return dict
    }
}

extension Array where Element: FFJSONable {
    var json: Any {
        return self.map { $0.json }
    }
}

extension FFFlame: FFJSONable {
    var json: Any {
        return ["A": affine.json, "B": blend, "C": color]
    }
}


extension FFStat: FFJSONable {
    var json: Any {
        return [ "x": x.json, "y": y.json, "v": v.json ]
    }
}

extension FFSpan: FFJSONable {
    var json: Any {
        return [ "min": min, "max": max ]
    }
}

protocol FFCSVable {
    var csv: [String] { get }
}

extension FFElement {
    var csv: [[String]] {
        let f = flames.map { $0.csv }
        return f
    }
}

extension FFFlame: FFCSVable {
    var csv: [String] {
        let a = affine.csv
        let b = blend.map { "\($0)" }
        let c = [ "\(color)" ]
        return a + b + c
    }
}

extension FFStat: FFCSVable {
    var csv: [String] { return x.csv + y.csv + v.csv }
}

extension FFSpan: FFCSVable {
    var csv: [String] { return [ "\(min)", "\(max)" ] }
}


extension FFElement {

    static func arrayCreate(fromJSON: Any?) -> [FFElement] {
        guard let value = fromJSON else { return [] }
        if let a = value as? [Any] {
            return a.compactMap { FFElement.create(fromJSON: $0) }
        }
        return []
    }

    static func newElement() -> FFElement {
        return FFElement(varias: [], flames: [], children: [])
    }

    static func create(fromJSON: Any) -> FFElement? {
        if let dict = fromJSON as? [String: Any] {
            return create(fromDict: dict)
        }
        return nil
    }
    static func create(fromDict: [String: Any]) -> FFElement {
        let elt = FFElement.newElement()
        elt.varias = FFVaria.arrayCreate(fromJSON: fromDict["V"])
        elt.flames = FFFlame.arrayCreate(fromJSON: fromDict["F"])
        elt.children = FFElement.arrayCreate(fromJSON: fromDict["children"])
        elt.title = fromDict["title"] as? String
        elt.stat = FFStat.create(fromJSON: fromDict["stat"])
        return elt
    }
    static func readFile(name filePath: String) throws -> FFElement {
        let fileURL = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: fileURL)
        let json = try JSONSerialization.jsonObject(with: data)
        guard let elt = FFElement.create(fromJSON: json) else { fatalError() }
        return elt
    }
}

extension FFFlame {

    static func arrayCreate(fromJSON: Any?) -> [FFFlame] {
        guard let value = fromJSON else { return [] }
        if let a = value as? [Any] {
            return a.compactMap { FFFlame.create(fromJSON: $0) }
        }
        if let d = value as? [String: Any] {
            return [ FFFlame.create(fromDict: d) ].compactMap { $0 }
        }
        if let n = Int.create(fromJSON: value) {
            return (0 ..< n).map { _ in FFFlame.new() }
        }
        return []
    }

    static func create(fromJSON: Any) -> FFFlame? {
        if let dict = fromJSON as? [String: Any] {
            return create(fromDict: dict)
        }
        return nil
    }

    static func create(fromDict: [String: Any]) -> FFFlame? {
        let flame = FFFlame.new()
        flame.affine = FFAffine.create(fromJSON: fromDict["A"]) ?? .identity
        flame.blend = Float.arrayCreate(fromJSON: fromDict["B"])
        flame.color = Float.create(fromJSON: fromDict["C"]) ?? 0
        return flame
    }

    static func new() -> FFFlame {
        return FFFlame(affine: .identity, blend: [], color: 0)
    }
}


extension FFStat {

    static func create(fromJSON: Any?) -> FFStat? {
        guard let value = fromJSON else { return nil }
        if let dict = value as? [String: Any] {
            return create(fromDict: dict)
        }
        return nil
    }

    static func create(fromDict: [String: Any]) -> FFStat? {
        var stax: FFSpan? = nil
        if let x = fromDict["x"] {
            stax = FFSpan.create(fromJSON: x)
        }else{
            print("dict[x]=nil")
        }
        var stay: FFSpan? = nil
        if let y = fromDict["y"] {
            stay = FFSpan.create(fromJSON: y)
        }else{
            print("dict[y]=nil")
        }
        var stav: FFSpan? = nil
        if let v = fromDict["v"] {
            stav = FFSpan.create(fromJSON: v)
        }else{
            print("dict[v]=nil")
        }
        guard let sx = stax else {
            print("stat.x = nil")
            return nil
        }
        guard let sy = stay else {
            print("stat.y = nil")
            return nil
        }
        guard let sv = stav else {
            print("stat.v = nil")
            return nil
        }
        return FFStat(x: sx, y: sy, v: sv)
    }
}

extension FFSpan {
    static func create(fromJSON: Any) -> FFSpan? {
        if let dict = fromJSON as? [String: Any] {
            return create(fromDict: dict)
        }
        return nil
    }
    static func create(fromDict: [String: Any]) -> FFSpan? {
        guard let min = Float.create(fromJSON: fromDict["min"]) else { return nil }
        guard let max = Float.create(fromJSON: fromDict["max"]) else { return nil }
        return FFSpan(min: min, max: max)
    }
}

extension FFElement : CustomStringConvertible {
    var description: String {
        var buf: [String] = [ "\(varias)" ]
        buf += flames.enumerated().map { return "F\(Subscript(value: $0.offset)): \($0.element)" }
        return buf.joined(separator: "\n")
    }
}

extension FFFlame : CustomStringConvertible {
    var description: String {
        return "A={\(affine)}, B=\(blend), C=\(color)"
    }
}


extension Float {

    static func arrayCreate(fromJSON: Any?) -> [Float] {
        guard let v = fromJSON else { return [] } 
        if let a = v as? [Any] {
            return a.compactMap { Float.create(fromJSON: $0) }
        }
        if let f = Float.create(fromJSON: v) {
            return [ f ]
        }
        return []
    }

    static func create(fromJSON: Any?) -> Float? {
        guard let v = fromJSON else { return nil }
        if let f = v as? Float {
            return f
        }
        if let n = v as? NSDecimalNumber {
            return n.floatValue
        }
        return Float("\(v)")
    }
}

extension Int {
    static func create(fromJSON: Any?) -> Int? {
        guard let v = fromJSON else { return nil }
        if let i = v as? Int {
            return i
        }
        if let n = v as? NSNumber {
            return n.intValue
        }
        return Int("\(v)")
    }
}
