import XCTest
@testable import XMLFormatter

class XMLUInt8FormatterTests: XCTestCase {
    typealias Formatter = XMLUInt8Formatter
    typealias Value = Formatter.Value
    
    let min: Value = .min
    let max: Value = .max
    let zero: Value = 0
    let one: Value = 1
    
    func test_string_from_value() throws {
        let examples: [(Value, String)] = [
            (self.min, "\(self.min)"),
            (self.max, "\(self.max)"),
            (self.zero, "\(self.zero)"),
            (self.one, "\(self.one)"),
        ]
        
        let formatter = Formatter()
        
        for (value, expected) in examples {
            let string = try formatter.string(from: value)
            XCTAssertEqual(string, expected)
        }
    }
    
    func test_value_from_string_valid() throws {
        let examples: [(String, Value)] = [
            ("\(self.min)", self.min),
            ("\(self.max)", self.max),
            ("\(self.zero)", self.zero),
            ("\(self.one)", self.one),
            
            ("+42", 42),
        ]
        
        let formatter = Formatter()
        
        for (string, expected) in examples {
            let value = try formatter.value(from: string)
            XCTAssertEqual(value, expected)
        }
    }
    
    func test_value_from_string_invalid() throws {
        let examples: [String] = [
            "98765432109876543210",
            "-42",
            "  42  ",
            "foobar",
            "      ",
            "",
        ]
        
        let formatter = Formatter()
        
        for string in examples {
            XCTAssertThrowsError(try formatter.value(from: string))
        }
    }
}
