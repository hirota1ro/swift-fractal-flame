import XCTest
@testable import FractalFlame

class FilePathResolverTests: XCTestCase {

    func testFilePathResolver() throws {
        let fpr = SuffixFilePathResolver(path: "/var/tmp/a.png")
        let url1 = fpr.resolve(suffix: "123")
        XCTAssertEqual(url1.path, "/var/tmp/a-123.png")
    }
}
