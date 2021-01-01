import XCTest
@testable import SwiftOniguruma

final class SwiftOnigurumaTests: XCTestCase {
    func testSimple() {
//        let testString = "asdfasdfasdgvq35yb657njbwh4v5geqrf"
//        let regex = try! NSRegularExpression(pattern: "[a-z]at")

        let regex = try? OnigRegularExpression(from: "a(.*)b|[e-f]+")
        XCTAssertNotNil(regex)

        try? regex!.search(in: "zzzzaffffffffb")
//        let range = NSRange(location: 0, length: testString.utf16.count)
//        _ = regex.firstMatch(in: testString, options: [], range: range) != nil
    }

    func testVersion() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(OnigRegularExpression.version, "6.9.6")
    }

    static var allTests = [
        ("testSimple", testSimple),
        ("testVersion", testVersion),
    ]
}
