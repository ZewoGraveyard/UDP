import XCTest
@testable import UDP

class UDPTests: XCTestCase {
    func testReality() {
        XCTAssert(2 + 2 == 4, "Something is severely wrong here.")
    }
}

extension UDPTests {
    static var allTests : [(String, (UDPTests) -> () throws -> Void)] {
        return [
           ("testReality", testReality),
        ]
    }
}
