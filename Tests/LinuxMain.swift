import XCTest

import firebase_dylib_xcode_genTests

var tests = [XCTestCaseEntry]()
tests += firebase_dylib_xcode_genTests.allTests()
XCTMain(tests)