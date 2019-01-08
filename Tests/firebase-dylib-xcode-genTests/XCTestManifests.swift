import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(firebase_dylib_xcode_genTests.allTests),
    ]
}
#endif