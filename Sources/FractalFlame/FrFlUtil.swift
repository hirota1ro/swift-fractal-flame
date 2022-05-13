import Cocoa

extension FFElement {

    func writeTo(fileURL: URL) throws {
        let data = try JSONSerialization.data(withJSONObject: self.json, options: [ .prettyPrinted, .sortedKeys ])
        do {
            try data.write(to: fileURL, options: .atomic)
            print("succeeded to write \(fileURL.path)")
        } catch {
            print("failed to write \(error)")
        }
    }
}

extension NSImage {

    func writeTo(fileURL: URL) {
        guard let data = self.pngData else {
            print("no png data")
            return
        }
        do {
            try data.write(to: fileURL, options: .atomic)
            print("succeeded to write \(fileURL.path)")
        } catch {
            print("failed to write \(error)")
        }
    }
}
