import Foundation

struct Subscript {
    let value: Int
}

extension Subscript: CustomStringConvertible {

    static let table: [Character: String] = [
      "0": "₀", // U+2080
      "1": "₁", // U+2081
      "2": "₂", // U+2082
      "3": "₃", // U+2083
      "4": "₄", // U+2084
      "5": "₅", // U+2085
      "6": "₆", // U+2086
      "7": "₇", // U+2087
      "8": "₈", // U+2088
      "9": "₉", // U+2089
      "-": "₋", // U+208B
    ]

    var description: String {
        let s = "\(value)"
        let t = s.compactMap { Subscript.table[$0] }
        return t.joined()
    }
}
