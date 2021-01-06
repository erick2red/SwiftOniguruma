import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwiftOnigurumaTests.allTests),
        testCase(SwiftOnigurumaRegexSetTests.allTests),
    ]
}
#endif
