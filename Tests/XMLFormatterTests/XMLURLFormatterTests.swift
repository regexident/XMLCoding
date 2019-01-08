import XCTest
@testable import XMLFormatter

class XMLURLFormatterTests: XCTestCase {
    typealias Formatter = XMLURLFormatter
    typealias Value = Formatter.Value
    
    func test_string_from_value() throws {
        let examples: [(Value, String)] = [
            (
                URL(string: "http://example.com")!,
                "http://example.com"
            ),
            (
                URL(string: "http://example.com/dir/file.html?key=value#anchor")!,
                "http://example.com/dir/file.html?key=value#anchor"
            ),
            (
                URL(string: "file:///Users/janedoe/")!,
                "file:///Users/janedoe/"
            ),
        ]
        
        let formatter = Formatter()
        
        for (value, expected) in examples {
            let string = try formatter.string(from: value)
            XCTAssertEqual(string, expected)
        }
    }
    
    func test_value_from_string_valid() throws {
        let examples: [(String, Value)] = [
            (
                "http://example.com",
                URL(string: "http://example.com")!
            ),
            (
                "http://example.com/dir/file.html?key=value#anchor",
                URL(string: "http://example.com/dir/file.html?key=value#anchor")!
            ),
            (
                "file:///Users/janedoe/",
                URL(string: "file:///Users/janedoe/")!
            ),
        ]
        
        let formatter = Formatter()
        
        for (string, expected) in examples {
            let value = try formatter.value(from: string)
            XCTAssertEqual(value, expected)
        }
    }
    
    func test_value_from_string_invalid() throws {
        let examples: [String] = [
            "!@#$%^&*()_+",
            "http://example.com\n",
            "      ",
            "",
        ]
        
        let formatter = Formatter()
        
        for string in examples {
            XCTAssertThrowsError(try formatter.value(from: string))
        }
    }
}
