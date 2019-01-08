import XCTest
@testable import XMLFormatter

class XMLUIntFormatterTests: XCTestCase {
    typealias Formatter = XMLUIntFormatter
    typealias Value = Formatter.Value
    
    func test_string_from_value() throws {
        let examples: [(Value, String)] = [
            (1, "1"),
            (0, "0"),
            (12_678_967_543_233, "12678967543233"),
        ]
        
        let formatter = Formatter()
        
        for (value, expected) in examples {
            let string = try formatter.string(from: value)
            XCTAssertEqual(string, expected)
        }
    }
    
    func test_value_from_string_valid() throws {
        let examples: [(String, Value)] = [
            ("1", 1),
            ("0", 0),
            ("12678967543233", 12678967543233),
            ("+100000", 100000),
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
