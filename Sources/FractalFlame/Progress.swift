import Foundation

fileprivate func puts(_ s: String) {
    print(s, terminator: "")
    fflush(stdout)
}

struct DeterminableProgress: FrFlProgress {
    func begin() {}
    func progress(_ value: Float) {
        let s = createProgressString(numerator: Int(value * 10), denominator: 10)
        let t = String(format: "%.1f", value * 100)
        print("[\(s)]\(t)%")
    }
    func end() {}

    func createProgressString(numerator: Int, denominator: Int) -> String {
        let n = (0 ..< numerator).map { _ in "#" }
        let m = (0 ..< (denominator - numerator)).map { _ in "-" }
        let a = n.joined()
        let b = m.joined()
        return "\(a)\(b)"
    }
}

struct IndeterminableProgress: FrFlProgress {
    func begin() {
        puts("[")
    }
    func progress(_ value: Float) {
        puts(".")
    }
    func end() {
        puts("] ")
    }
}

class MeasurementProgress: FrFlProgress {
    let original: FrFlProgress
    var start: Date = Date()
    init(_ original: FrFlProgress) {
        self.original = original
    }

    func begin() {
        original.begin()
        self.start = Date()
    }
    func progress(_ value: Float) {
        original.progress(value)
    }
    func end() {
        let elapsed = Date().timeIntervalSince(start)
        original.end()
        let s = String(format: "%.2f", elapsed)
        puts("(\(s)s) ")
    }
}

struct EmptyProgress: FrFlProgress {
    func begin() {}
    func progress(_ value: Float) {}
    func end() {}
}
