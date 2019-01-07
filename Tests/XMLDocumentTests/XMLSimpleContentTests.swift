import XCTest
@testable import XMLDocument

class XMLSimpleContentTests: XCTestCase {
    func testStringItem() {
        let string = "foo"
        
        let subject: XMLSimpleContent = .string(string)
        
        XCTAssertEqual(subject.string, string)
        
        XCTAssertNil(subject.data)
    }
    
    func testDataItem() {
        let string = "foo"
        let data = string.data(using: .utf8)!
        
        let subject: XMLSimpleContent = .data(data)
        
        XCTAssertEqual(subject.data, data)
        
        XCTAssertNil(subject.string, string)
    }
}
