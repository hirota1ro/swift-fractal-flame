import Foundation

extension FractalFlame.ExpandVariation {

    mutating func run() throws {
        let element = try FFElement.readFile(name: inputFile)
        var varias: [FFVaria] = element.varias
        let flames: [FFFlame] = element.flames
        let parent = FFElement(varias: [], flames: [], children: [])
        let imageProgress = MeasurementProgress(IndeterminableProgress())

        for varia: FFVaria in FFVaria.all {
            varias[index] = varia
            
            let child = FFElement(varias: varias, flames: flames, children: [])

            let stat = FrFlStatSpan()
            let succeeded = child.fractalFlame.draw(iterations: 100_000, plotter: stat, progress: imageProgress)
            if succeeded && stat.isValid {
                print("succeeded: \(stat)")
                child.stat = stat.node

                parent.add(child: child)
            } else {
                print("failed: \(stat)")
            }
        }

        let fileURL = URL(fileURLWithPath: outputFile)
        try parent.writeTo(fileURL: fileURL)
    }
}
