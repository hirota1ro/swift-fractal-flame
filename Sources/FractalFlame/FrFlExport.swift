import Cocoa

extension FractalFlame.Export {

    mutating func run() throws {
        let element = try FFElement.readFile(name: inputFile)
        let array = createTable(root: element)
        let text = array.joined(separator: "\n")
        if let outputFile = outputFile,
           let data = text.data(using: .utf8) {
            let fileURL = URL(fileURLWithPath: outputFile)
            do {
                try data.write(to: fileURL, options: .atomic)
                print("succeeded to write \(outputFile)")
            } catch {
                print("\(error)")
            }
        } else {
            print(text)
        }
    }

    func createTable(root: FFElement) -> [String] {
        var array: [String] = []
        root.traverse { (elt: FFElement, idxs: IndexPath) in
            if elt.isValid {
                if array.isEmpty {
                    let bv = (0 ..< elt.varias.count).map({ "b\($0)" }).joined(separator: ", ")
                    array.append("#,%, a, b, c, d, tx, ty, \(bv), h")
                }
                elt.flames.forEach {
                    let line = $0.csv.joined(separator: ", ")
                    array.append("\(idxs.pathLike), \(line)")
                }
            }
        }
        array.append("#,%, xmin, xmax, ymin, ymax, vmin, vmax, Tx, Ty, Scale, Vspan")
        root.traverse { (elt: FFElement, idxs: IndexPath) in
            if let stat = elt.stat {
                let a = stat.csv + stat.extra
                let line = a.joined(separator: ", ")
                array.append("\(idxs.pathLike), \(line)")
            }
        }
        return array
    }
}

extension FFStat {

    /// - Returns: Tx, Ty, Scale, Vspan
    var extra: [String] {
        let tx = -x.center
        let ty = -y.center
        let size = CGSize(width: CGFloat(x.value), height: CGFloat(y.value))
        let scale = Float(size.scaleToFit(CGSize(width: 2, height: 2)))
        let vspan = v.value
        return ["\(tx)", "\(ty)", "\(scale)", "\(vspan)"]
    }
}
