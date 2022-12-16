import Foundation

protocol FilePathResolver {
    func resolve(suffix: String) -> URL
}


struct ConstFilePathResolver {
    let path: String
}
extension ConstFilePathResolver: FilePathResolver {

    func resolve(suffix: String) -> URL {
        return URL(fileURLWithPath: path)
    }
}


struct SuffixFilePathResolver {
    let path: String
}
extension SuffixFilePathResolver: FilePathResolver {

    func resolve(suffix: String) -> URL {
        let fileURL = URL(fileURLWithPath: path)
        let ext: String = fileURL.pathExtension
        let basename: String = fileURL.deletingPathExtension().lastPathComponent
        let name = "\(basename)-\(suffix).\(ext)"
        let dirURL = fileURL.deletingLastPathComponent()
        return dirURL.appendingPathComponent(name)
    }
}
