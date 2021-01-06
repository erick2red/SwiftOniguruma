import XCTest
@testable import SwiftOniguruma

final class SwiftOnigurumaRegexSetTests: XCTestCase {
    func testMatch() {
        let set = try? OnigRegexSet()
        XCTAssertNotNil(set)

        let abRegex = try? OnigRegularExpression(pattern: "a(.*)b")
        XCTAssertNotNil(abRegex)
        let efRegex = try? OnigRegularExpression(pattern: "[e-f]+")
        XCTAssertNotNil(efRegex)

        try? set!.add(abRegex!)
        try? set!.add(efRegex!)

        let source = "zzzzaffffffffb"
        let match = try? set!.firstMatch(in: source)
        XCTAssertNotNil(match)
        XCTAssertNotNil(match!.regex)
        XCTAssert(match!.regex!.pattern == "a(.*)b")
        XCTAssert(match!.matches.isEmpty == false)
        XCTAssert(match!.matches.count == 2)
        XCTAssert(match!.matches[0] == (4, 14))
        XCTAssert(match!.matches[1] == (5, 13))

        var start = source.index(source.startIndex, offsetBy: match!.matches[0].0)
        var end = source.index(source.startIndex, offsetBy: match!.matches[0].1)
        var matched = source[start..<end]
        XCTAssert(matched == "affffffffb")

        start = source.index(source.startIndex, offsetBy: match!.matches[1].0)
        end = source.index(start, offsetBy: match!.matches[1].1 - match!.matches[1].0)
        matched = source[start..<end]
        XCTAssert(matched == "ffffffff")
    }

    func testMemory() {
        for _ in 0..<300 {
            let set = try? OnigRegexSet()
            XCTAssertNotNil(set)

            let abRegex = try? OnigRegularExpression(pattern: "a(.*)b")
            XCTAssertNotNil(abRegex)
            let efRegex = try? OnigRegularExpression(pattern: "[e-f]+")
            XCTAssertNotNil(efRegex)

            try? set!.add(abRegex!)
            try? set!.add(efRegex!)

            let source = "zzzzaffffffffb"
            let match = try? set!.firstMatch(in: source)
            XCTAssertNotNil(match)
            XCTAssertNotNil(match!.regex)
            XCTAssert(match!.regex!.pattern == "a(.*)b")
            XCTAssert(match!.matches.isEmpty == false)
            XCTAssert(match!.matches.count == 2)
            XCTAssert(match!.matches[0] == (4, 14))
            XCTAssert(match!.matches[1] == (5, 13))

            var start = source.index(source.startIndex, offsetBy: match!.matches[0].0)
            var end = source.index(source.startIndex, offsetBy: match!.matches[0].1)
            var matched = source[start..<end]
            XCTAssert(matched == "affffffffb")

            start = source.index(source.startIndex, offsetBy: match!.matches[1].0)
            end = source.index(start, offsetBy: match!.matches[1].1 - match!.matches[1].0)
            matched = source[start..<end]
            XCTAssert(matched == "ffffffff")
        }
    }

    static var allTests = [
        ("testMatch", testMatch),
        ("testMemory", testMemory),
    ]
}
