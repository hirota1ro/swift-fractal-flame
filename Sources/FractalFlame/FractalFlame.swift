import Foundation
import ArgumentParser

@main
struct FractalFlame: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Utilities for Fractal Flames.",
      subcommands: [Image.self, Search.self, Interpolate.self, Rotate.self,
                    ExpandVariation.self, Export.self,
                    VisualizeVariation.self, VisualizeAffine.self],
      defaultSubcommand: Image.self,
      helpNames: [.long, .customShort("?")])
}

extension FractalFlame {
    struct Image: ParsableCommand {
        static var configuration
          = CommandConfiguration(abstract: "Create PNG image specified ffdoc")

        @Argument(help: "ffdoc file")
        var inputFile: String

        @Option(name: .shortAndLong, help: "The number of image width")
        var width: Int = 512

        @Option(name: .shortAndLong, help: "The number of image height (default: same as the width)")
        var height: Int?

        @Option(name: [.customShort("N"), .long], help: "The number of iterations")
        var iterations: Int = 100_000

        @Option(name: .shortAndLong, help: "When scale is 1.0, the range [-1,1] is expanded to just image width")
        var scale: Float = 1

        @Option(name: .shortAndLong, help: "The number of high density")
        var density: Int = 1

        @Option(name: .shortAndLong, help: "Gamma factor: enabled when density>1")
        var gamma: Float = 0.5

        @Flag(name: .long, help: "Flip vertical")
        var verticalFlip: Bool = false

        @Flag(name: .long, help: "Flip horizontal")
        var horizontalFlip: Bool = false

        @Flag(name: .long, inversion: .prefixedNo, help: "If true, assumes a black background")
        var dark: Bool = true

        @Flag(name: .long, help: "If false, fill background opaque color")
        var transparent: Bool = false

        @Option(name: [.customShort("F"), .long], help: "color factor")
        var colorFactor: Float = 10

        @Option(name: .shortAndLong, help: "output file path")
        var outputFile: String = "FF.png"
    }

    struct Search: ParsableCommand {
        static var configuration
          = CommandConfiguration(abstract: "Search randomly, create ffdoc file")

        @Argument(help: "ffdoc file")
        var inputFile: String

        @Option(name: .shortAndLong, help: "the number of search count")
        var count: Int = 10

        @Option(name: .shortAndLong, help: "the value to judge the image as good.")
        var threshold: Float = 0.1

        @Option(name: [.customShort("C"), .long], help: "the number of concession")
        var concession: Int = 100

        @Flag(name: [.customShort("b"), .long], help: "starts from base element and searches nearby.")
        var useBaseElement: Bool = false

        @Option(name: .shortAndLong, help: "The number of image width")
        var width: Int = 512

        @Option(name: .shortAndLong, help: "The number of image height (default: same as the width)")
        var height: Int?

        @Option(name: .shortAndLong, help: "When scale is 1.0, the range [-1,1] is expanded to just image width")
        var scale: Float = 1

        @Option(name: [.customShort("N"), .long], help: "The number of iterations")
        var iterations: Int = 10_000

        @Option(name: .shortAndLong, help: "output file path")
        var outputFile: String = "FF-found.ffdoc"
    }

    struct Interpolate: ParsableCommand {
        static var configuration
          = CommandConfiguration(abstract: "Interpolate between flames, then create new ffdoc")

        @Argument(help: "ffdoc file")
        var inputFile: String

        @Option(name: .shortAndLong, help: "number of interporation")
        var count: Int = 10

        @Option(name: .shortAndLong, help: "output file path")
        var outputFile: String = "FF-inter.ffdoc"
    }

    struct Rotate: ParsableCommand {
        static var configuration
          = CommandConfiguration(abstract: "Rotate flame")

        @Argument(help: "ffdoc file")
        var inputFile: String

        @Option(name: .shortAndLong, help: "number of interporation")
        var count: Int = 10

        @Option(name: .shortAndLong, help: "output file path")
        var outputFile: String = "FF-rotated.ffdoc"
    }

    struct ExpandVariation: ParsableCommand {
        static var configuration
          = CommandConfiguration(abstract: "Expand variation, then create new ffdoc")

        @Argument(help: "ffdoc file")
        var inputFile: String

        @Option(name: .shortAndLong, help: "index in an array of variation")
        var index: Int = 0

        @Option(name: .shortAndLong, help: "output file path")
        var outputFile: String = "FF-varia.ffdoc"
    }

    struct Export: ParsableCommand {
        static var configuration
          = CommandConfiguration(abstract: "Export CSV file from ffdoc")

        @Argument(help: "ffdoc file")
        var inputFile: String

        @Option(name: .shortAndLong, help: "output file path (default stdout)")
        var outputFile: String?
    }

    struct VisualizeVariation: ParsableCommand {
        static var configuration
          = CommandConfiguration(abstract: "Create PNG image specified variations")

        @Argument(help: "ffdoc file")
        var inputFile: String

        @Option(name: .shortAndLong, help: "The number of image width")
        var width: Int = 512

        @Option(name: .shortAndLong, help: "The number of image height (default: same as the width)")
        var height: Int?

        @Option(name: .shortAndLong, help: "Scale factor: [-1,1]×[-1,1] to (width×height)*scale")
        var scale: Float = 0.5

        @Option(name: .shortAndLong, help: "output file path")
        var outputFile: String = "FF-variation.png"
    }

    struct VisualizeAffine: ParsableCommand {
        static var configuration
          = CommandConfiguration(abstract: "Create PNG image specified affine transform")

        @Argument(help: "ffdoc file")
        var inputFile: String

        @Option(name: .shortAndLong, help: "The number of image width")
        var width: Int = 512

        @Option(name: .shortAndLong, help: "The number of image height (default: same as the width)")
        var height: Int?

        @Option(name: .shortAndLong, help: "Scale factor: [-1,1]×[-1,1] to (width×height)*scale")
        var scale: Float = 0.5

        @Option(name: .shortAndLong, help: "output file path")
        var outputFile: String = "FF-affine.png"
    }
}
