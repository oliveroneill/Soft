import XCTest

import SpitTests

var tests = [XCTestCaseEntry]()
tests += SpitTests.allTests()
XCTMain(tests)