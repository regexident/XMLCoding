import XCTest
@testable import XMLFormatter

extension Decimal {
    static let infinity: Decimal = .init(.infinity)
    static let nan: Decimal = .init(.nan)
}

class XMLDecimalFormatterTests: XCTestCase {
    typealias Formatter = XMLDecimalFormatter
    typealias Value = Formatter.Value
    
    func test_string_from_value() throws {
        let examples: [(Value, String)] = [
            (-3e2, "-300"),
            (4268.22752e11, "426822752000000"),
            (+24.3e-3, "0.02429999999999999488"),
            (12.3, "12.3"),
            (-12.3, "-12.3"),
            (0.0, "0"),
            (-0.0, "0"),
//            (.infinity, "INF"),
//            (-.infinity, "-INF"),
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
            ("-3E2", -3E2),
            ("4268.22752E11", 4268.22752E11),
            ("12", 12.0),
            ("+3.5", +3.5),
//            ("INF", .infinity),
//            ("-INF", -.infinity),
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
            "INF",
            "-INF",
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
