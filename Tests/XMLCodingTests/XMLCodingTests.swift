import XCTest
@testable import XMLCoding

final class XMLCodingTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(XMLCoding().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
