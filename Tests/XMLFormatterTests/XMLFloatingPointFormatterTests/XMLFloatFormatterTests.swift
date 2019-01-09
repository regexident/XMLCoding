import XCTest
@testable import XMLFormatter

class XMLFloatFormatterTests: XCTestCase {
    typealias Formatter = XMLFloatFormatter
    typealias Value = Formatter.Value
    
    func test_string_from_value() throws {
        let examples: [(Value, String)] = [
            (-3e2, "-300.0"),
            (4268.22752e11, "4.2682274e+14"),
            (+24.3e-3, "0.0243"),
            (12.3, "12.3"),
            (-12.3, "-12.3"),
            (0.0, "0.0"),
            (-0.0, "-0.0"),
            (.infinity, "INF"),
            (-.infinity, "-INF"),
            (.nan, "NaN"),
        ]
        
        let formatter = Formatter()
        
        for (value, expected) in examples {
            let string = try formatter.string(from: value)
            XCTAssertEqual(string, expected)
        }
    }
    
    func test_value_from_string_valid() throws {
        let examples: [(String, Value)] = [
            ("-3E2", -3e2),
            ("4268.22752E11", 4268.22752e11),
            ("+24.3e-3", +24.3e-3),
            ("12", 12.0),
            ("+3.5", +3.5),
            ("INF", .infinity),
            ("-INF", -.infinity),
            ("0", 0.0),
            ("-0", -0.0),
            ("NaN", .nan),
        ]
        
        let formatter = Formatter()
        
        for (string, expected) in examples {
            let value = try formatter.value(from: string)
            
            if expected.isNaN {
                XCTAssertTrue(value.isNaN)
            } else {
                XCTAssertEqual(value, expected)
            }
        }
    }
    
    func test_value_from_string_invalid() throws {
        let examples: [String] = [
            "-3E2.4",
            "12E",
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
    
    static var allTests = [
        ("test_string_from_value", test_string_from_value),
        ("test_value_from_string_valid", test_value_from_string_valid),
        ("test_value_from_string_invalid", test_value_from_string_invalid),
    ]
}
