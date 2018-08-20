import XCTest

import SoftTests

var tests = [XCTestCaseEntry]()
tests += SoftTests.__allTests()

XCTMain(tests)
