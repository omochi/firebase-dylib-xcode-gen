import XCTest
@testable import firebase_dylib_xcode_gen

final class firebase_dylib_xcode_genTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(firebase_dylib_xcode_gen().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
