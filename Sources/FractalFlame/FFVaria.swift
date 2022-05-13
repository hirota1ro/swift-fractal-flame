import Foundation

class FFVaria: FFNode {
    var name: String
    var param: FFVariaParam
    init(name: String, param: FFVariaParam = FFVariaParam()) {
        self.name = name
        self.param = param
    }
}

extension FFVaria {
    var variation: FrFl.VF? {
        return FrFl.obtain(name: name, param: param.dict)
    }
}

extension FFVaria {
    var clone: FFVaria {
        return FFVaria(name: name, param: param.clone)
    }
}

extension FFVaria: FFJSONable {
    var json: Any {
        if param.isEmpty {
            return name
        } else {
            var dict:[String: Any] = param.dict
            dict["name"] = name
            return dict
        }
    }
}

extension FFVaria: FFCSVable {
    var csv: [String] {
        if param.isEmpty {
            return [ name ]
        } else {
            var array:[String] = [ name ]
            array += param.csv
            return array
        }
    }
}

extension FFVaria {

    static func arrayCreate(fromJSON: Any?) -> [FFVaria] {
        guard let value = fromJSON else { return [] }
        if let a = value as? [Any] {
            return a.compactMap { FFVaria.create(fromJSON: $0) }
        }
        if let d = value as? [String: Any] {
            return [ FFVaria.create(fromDict: d) ].compactMap { $0 }
        }
        if let s = value as? String {
            return [ FFVaria(name: s) ]
        }
        return []
    }

    static func create(fromJSON: Any) -> FFVaria? {
        if let dict = fromJSON as? [String: Any] {
            return create(fromDict: dict)
        }
        if let name = fromJSON as? String {
            return FFVaria(name: name)
        }
        print("FFVaria: \(fromJSON) must be String or Dictionary")
        return nil
    }

    static func create(fromDict: [String: Any]) -> FFVaria? {
        var name: String? = nil
        var o: [String: Float] = [:]
        var a: [String] = []
        for (key, value) in fromDict {
            if key == "name" {
                name = value as? String
            } else {
                if let fval = Float.create(fromJSON: value) {
                    o[key] = fval
                    a.append(key)
                }
            }
        }
        guard let n = name else {
            print("FFVaria: \(fromDict) has no \"name\"")
            return nil
        }
        a.sort(by: <)
        return FFVaria(name: n, param: FFVariaParam(keys: a, dict: o))
    }
}

extension FFVaria {

    static let all: [FFVaria] = [
      FFVaria(name:"Linear"),
      FFVaria(name:"Sinusoidal"),
      FFVaria(name:"Spherical"),
      FFVaria(name:"Swirl"),
      FFVaria(name:"Horseshoe"),
      FFVaria(name:"Polar"),
      FFVaria(name:"Handkerchief"),
      FFVaria(name:"Heart"),
      FFVaria(name:"Disc"),
      FFVaria(name:"Spiral"),
      FFVaria(name:"Hyperbolic"),
      FFVaria(name:"Diamond"),
      FFVaria(name:"Ex"),
      FFVaria(name:"Julia"),
      FFVaria(name:"Bent"),
      FFVaria(name:"Waves"),
      FFVaria(name:"Fisheye"),
      FFVaria(name:"Popcorn"),
      FFVaria(name:"Exponential"),
      FFVaria(name:"Power"),
      FFVaria(name:"Cosine"),
      FFVaria(name:"Rings"),
      FFVaria(name:"Fan"),
      FFVaria(name:"Blob", param: FFVariaParam(["high": 1, "low": 0.5, "waves": 5])),
      FFVaria(name:"PDJ", param: FFVariaParam(["a": 1.3, "b": 1.7, "c": 0.9, "d": 1.8])),
      FFVaria(name:"Fan2", param: FFVariaParam(["x": 0.4, "y": 0.5])),
      FFVaria(name:"Rings2", param: FFVariaParam(["rings2": 0.5])),
      FFVaria(name:"Eyefish"),
      FFVaria(name:"Bubble"),
      FFVaria(name:"Cylinder"),
      FFVaria(name:"Perspective", param: FFVariaParam(["angle": 0.3, "dist": 0.6])),
      FFVaria(name:"Noise"),
      FFVaria(name:"JuliaN", param: FFVariaParam(["power": 3, "dist": 0.8])),
      FFVaria(name:"JuliaScope", param: FFVariaParam(["power": 4, "dist": 0.8])),
      FFVaria(name:"Blur"),
      FFVaria(name:"Gaussian"),
      FFVaria(name:"RadialBlur", param: FFVariaParam(["angle": 3, "dist": 1.0])),
      FFVaria(name:"Pie", param: FFVariaParam(["slices": 5, "rotation": 0.3, "thickness": 0.5])),
      FFVaria(name:"Ngon", param: FFVariaParam(["power": 2, "sides": 5, "corners":0.1, "circle": 0.7])),
      FFVaria(name:"Curl", param: FFVariaParam(["c1": 0.1, "c2": 0.8])),
      FFVaria(name:"Rectangles", param: FFVariaParam(["x": 0.3, "y": 0.7])),
      FFVaria(name:"Arch", param: FFVariaParam(["v41": 1.0])),
      FFVaria(name:"Tangent"),
      FFVaria(name:"Square"),
      FFVaria(name:"Rays", param: FFVariaParam(["v44": 1.0])),
      FFVaria(name:"Blade", param: FFVariaParam(["v45": 1.0])),
      FFVaria(name:"Secant", param: FFVariaParam(["v46": 1.0])),
      FFVaria(name:"Twintrian", param: FFVariaParam(["v47": 1.0])),
      FFVaria(name:"Cross"),
    ]
}

extension FFVaria : CustomStringConvertible {
    var description: String {
        if let va = variation {
            return "\(va)"
        }
        return "\(name)"
    }
}

// MARK: -

class FFVariaParam {
    let keys: [String]
    var dict: [String: Float]
    init(keys: [String] = [], dict: [String: Float] = [:]) {
        self.keys = keys
        self.dict = dict
    }
    init(_ a: KeyValuePairs<String, Float>) {
        var keys: [String] = []
        var dict: [String: Float] = [:]
        for e in a {
            keys.append(e.key)
            dict[e.key] = e.value
        }
        self.keys = keys
        self.dict = dict
    }
    var count: Int { return keys.count }
    subscript(key: String) -> Float? {
        get { return dict[key] }
        set { dict[key] = newValue }
    }
    var isEmpty: Bool { return keys.isEmpty }
}

extension FFVariaParam {
    var clone: FFVariaParam {
        return FFVariaParam(keys: keys, dict: dict)
    }
}

extension FFVariaParam: FFCSVable {
    var csv: [String] {
        return keys.compactMap( { dict[$0] }).map( { "\($0)" })
    }
}

extension FFVariaParam : CustomStringConvertible {
    var description: String {
        let a = dict.map { (key: String, value: Float) -> String in return "\(key):\(value)" }
        return "\(a.joined(separator: ", "))"
    }
}
