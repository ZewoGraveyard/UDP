#if os(Linux)

import XCTest
@testable import UDPTestSuite

XCTMain([
    testCase(UDPTests.allTests)
])

#endif
