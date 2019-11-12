import XCTest
@testable import XMLCoding

class XMLCodingKeyTests: XCTestCase {
    func test_init_stringValue() {
        let string = "foo"
        let codingKeyOrNil = XMLCodingKey(stringValue: string)
        
        XCTAssertNotNil(codingKeyOrNil)
        
        guard let codingKey = codingKeyOrNil else {
            return
        }
        
        XCTAssertEqual(codingKey.stringValue, string)
        XCTAssertNil(codingKey.intValue)
    }
    
    func test_init_intValue() {
        let int = 42
        let codingKeyOrNil = XMLCodingKey(intValue: int)
        
        XCTAssertNotNil(codingKeyOrNil)
        
        guard let codingKey = codingKeyOrNil else {
            return
        }
        
        XCTAssertEqual(codingKey.stringValue, "Index 42")
        XCTAssertEqual(codingKey.intValue, int)
    }
    
    func test_init_key() {
        let key = "foo"
        let codingKey = XMLCodingKey(key: key)
        
        XCTAssertEqual(codingKey.stringValue, key)
        XCTAssertNil(codingKey.intValue)
    }
    
    func test_init_index() {
        let index = 42
        let codingKey = XMLCodingKey(index: index)
        
        XCTAssertEqual(codingKey.stringValue, "Index 42")
        XCTAssertEqual(codingKey.intValue, index)
    }
    
    static var allTests = [
        ("test_init_stringValue", test_init_stringValue),
        ("test_init_intValue", test_init_intValue),
        ("test_init_key", test_init_key),
        ("test_init_index", test_init_index),
    ]
}
