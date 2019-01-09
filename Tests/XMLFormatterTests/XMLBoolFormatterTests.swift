import XCTest
@testable import XMLFormatter

class XMLBoolFormatterTests: XCTestCase {
    typealias Formatter = XMLBoolFormatter
    typealias Value = Formatter.Value
    
    func test_string_from_value() throws {
        let examples: [(Value, String)] = [
            (false, "false"),
            (true, "true"),
        ]
        
        let formatter = Formatter()
        
        for (value, expected) in examples {
            let string = try formatter.string(from: value)
            XCTAssertEqual(string, expected)
        }
    }
    
    func test_value_from_string() throws {
        let examples: [(String, Value)] = [
            ("false", false),
            ("true", true),
            ("0", false),
            ("1", true),
        ]
        
        let formatter = Formatter()
        
        for (string, expected) in examples {
            let value = try formatter.value(from: string)
            XCTAssertEqual(value, expected)
        }
    }
    
    func test_value_from_string_invalid() throws {
        let examples: [String] = [
            "42",
            "foobar",
            "      ",
            "",
        ]
        
        let formatter = Formatter()
        
        for string in examples {
            XCTAssertThrowsError(try formatter.value(from: string))
        }
    }
    
    static var allTests = [
        ("test_string_from_value", test_string_from_value),
        ("test_value_from_string", test_value_from_string),
        ("test_value_from_string_invalid", test_value_from_string_invalid),
    ]
}
