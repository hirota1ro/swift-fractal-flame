import Foundation

struct FilePathResolver {
    let path: String
}

extension FilePathResolver {

    func resolve(suffix: String) -> URL {
        let fileURL = URL(fileURLWithPath: path)
        let ext: String = fileURL.pathExtension
        let basename: String = fileURL.deletingPathExtension().lastPathComponent
        let name = "\(basename)-\(suffix).\(ext)"
        let dirURL = fileURL.deletingLastPathComponent()
        return dirURL.appendingPathComponent(name)
    }
}
