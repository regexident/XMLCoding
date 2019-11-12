import XCTest
@testable import XMLFormatter

class XMLFormatterTests: XCTestCase {
    struct Formatter: XMLFormatter {
        typealias Value = String
        
        enum Error: Swift.Error {
            case invalidValue
        }
        
        func value(from string: String) throws -> Value {
            return string
        }
        
        func string(from value: Value) throws -> String {
            return value
        }
    }
    
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
    
    func test_data_from_value() throws {
        let examples: [(Value, Data)] = [
            ("lorem ipsum", "lorem ipsum".data(using: .utf8)!),
            ("lorem\nipsum", "lorem\nipsum".data(using: .utf8)!),
        ]
        
        let formatter = Formatter()
        
        for (value, expected) in examples {
            let string = try formatter.data(from: value)
            XCTAssertEqual(string, expected)
        }
    }
    
    func test_data_from_value_invalid() throws {
        let value = String(data: Data([0xde, 0xad, 0xbe, 0xef]), encoding: .utf16)!
        
        let formatter = Formatter()
        
        let data = try formatter.data(from: value, encoding: .utf8)
        let expected = Data([0xef, 0xbf, 0xbd, 0xeb, 0xbb, 0xaf])
        XCTAssertEqual(data, expected)
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
    
    func test_value_from_data() throws {
        let examples: [(Data, Value)] = [
            ("lorem ipsum".data(using: .utf8)!, "lorem ipsum"),
            ("lorem\nipsum".data(using: .utf8)!, "lorem\nipsum"),
        ]
        
        let formatter = Formatter()
        
        for (data, expected) in examples {
            let value = try formatter.value(from: data)
            XCTAssertEqual(value, expected)
        }
    }
    
    func test_value_from_data_invalid() throws {
        let data = Data([0xde, 0xad, 0xbe, 0xef])
        
        let formatter = Formatter()
        
        XCTAssertThrowsError(try formatter.value(from: data, encoding: .utf8))
    }
    
    static var allTests = [
        ("test_string_from_value", test_string_from_value),
        ("test_data_from_value", test_data_from_value),
        ("test_data_from_value_invalid", test_data_from_value_invalid),
        ("test_value_from_string", test_value_from_string),
        ("test_value_from_data", test_value_from_data),
        ("test_value_from_data_invalid", test_value_from_data_invalid),
    ]
}
