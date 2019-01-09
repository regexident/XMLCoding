import XCTest
@testable import XMLFormatter

class XMLStringFormatterTests: XCTestCase {
    typealias Formatter = XMLStringFormatter
    typealias Value = Formatter.Value
    
    func test_string_from_value() throws {
        let examples: [(Value, String)] = [
            ("lorem ipsum", "lorem ipsum"),
            ("lorem\nipsum", "lorem\nipsum"),
        ]
        
        let formatter = Formatter()
        
        for (value, expected) in examples {
            let string = try formatter.string(from: value)
            XCTAssertEqual(string, expected)
        }
    }
    
    func test_value_from_string() throws {
        let examples: [(String, Value)] = [
            ("lorem ipsum", "lorem ipsum"),
            ("lorem\nipsum", "lorem\nipsum"),
        ]
        
        let formatter = Formatter()
        
        for (string, expected) in examples {
            let value = try formatter.value(from: string)
            XCTAssertEqual(value, expected)
        }
    }
    
    static var allTests = [
        ("test_string_from_value", test_string_from_value),
        ("test_value_from_string", test_value_from_string),
    ]
}
