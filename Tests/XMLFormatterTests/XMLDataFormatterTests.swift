import XCTest
@testable import XMLFormatter

class XMLDataFormatterTests: XCTestCase {
    typealias Formatter = XMLDataFormatter
    typealias Value = Formatter.Value
    
    typealias TestAction<T, U> = (T, Formatter) throws -> U
    
    func withRawFormatter<T, U>(_ value: T, _ action: TestAction<T, U>) rethrows -> U {
        let formatter = Formatter(format: .raw)
        
        return try action(value, formatter)
    }
    
    func withBase64Formatter<T, U>(_ value: T, _ action: TestAction<T, U>) rethrows -> U {
        let formatter = Formatter(format: .base64)
        
        return try action(value, formatter)
    }
    
    func test_string_from_value() throws {
        typealias Strings = (raw: String, base64: String)
        let examples: [(Value, Strings)] = [
            (
                Data(),
                (raw: "", base64: "")
            ),
            (
                Data([0x64, 0x65, 0x61, 0x64, 0x62, 0x65, 0x65, 0x66]),
                (raw: "deadbeef", base64: "ZGVhZGJlZWY=")
            ),
        ]
        
        let action: TestAction = { value, formatter in
            return try formatter.string(from: value)
        }
        
        for (value, expected) in examples {
            let rawString: String = try self.withRawFormatter(value, action)
            XCTAssertEqual(rawString, expected.raw)
            
            let base64String: String = try self.withBase64Formatter(value, action)
            XCTAssertEqual(base64String, expected.base64)
        }
    }
    
    func test_string_from_value_invalid() throws {
        typealias Examples = (
            raw: [Value],
            base64: [Value]
        )
        
        let examples: Examples = (
            raw: [
                Data([0xde, 0xad, 0xbe, 0xef])
            ],
            base64: []
        )
        
        let action: TestAction = { value, formatter in
            return try formatter.string(from: value)
        }
        
        for value in examples.raw {
            XCTAssertThrowsError(try self.withRawFormatter(value, action))
        }
        
        for value in examples.base64 {
            XCTAssertThrowsError(try self.withBase64Formatter(value, action))
        }
    }
    
    func test_value_from_string() throws {
        typealias Strings = (raw: String, base64: String)
        
        let examples: [(Strings, Value)] = [
            (
                (raw: "", base64: ""),
                Data()
            ),
            (
                (raw: "deadbeef", base64: "ZGVhZGJlZWY="),
                Data([0x64, 0x65, 0x61, 0x64, 0x62, 0x65, 0x65, 0x66])
            ),
        ]
       
        let action: TestAction = { string, formatter in
            return try formatter.value(from: string)
        }
        
        for (string, expected) in examples {
            let rawValue: Value = try self.withRawFormatter(string.raw, action)
            XCTAssertEqual(rawValue, expected)
            
            let base64Value: Value = try self.withBase64Formatter(string.base64, action)
            XCTAssertEqual(base64Value, expected)
        }
    }
    
    func test_value_from_string_invalid() throws {
        typealias Examples = (
            raw: [String],
            base64: [String]
        )
        
        let examples: Examples = (
            raw: [],
            base64: [
                "lorem ipsum"
            ]
        )
        
        let action: TestAction = { string, formatter in
            return try formatter.value(from: string)
        }
        
        for string in examples.raw {
            XCTAssertThrowsError(try self.withRawFormatter(string, action))
        }
        
        for string in examples.base64 {
            XCTAssertThrowsError(try self.withBase64Formatter(string, action))
        }
    }
}
