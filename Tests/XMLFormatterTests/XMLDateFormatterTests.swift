import XCTest
@testable import XMLFormatter

class XMLDateFormatterTests: XCTestCase {
    typealias Formatter = XMLDateFormatter
    typealias Value = Formatter.Value
    
    typealias TestAction<T, U> = (T, Formatter) throws -> U
    
    func withSecondsSince1970Formatter<T, U>(_ value: T, _ action: TestAction<T, U>) rethrows -> U {
        let formatter = Formatter(format: .secondsSince1970)
        
        return try action(value, formatter)
    }
    
    func withMillisecondsSince1970Formatter<T, U>(_ value: T, _ action: TestAction<T, U>) rethrows -> U {
        let formatter = Formatter(format: .millisecondsSince1970)
        
        return try action(value, formatter)
    }
    
    func withIso8601Formatter<T, U>(_ value: T, _ action: TestAction<T, U>) rethrows -> U {
        let formatter = Formatter(format: .iso8601)
        
        return try action(value, formatter)
    }
    
    func withCustomFormatter<T, U>(_ value: T, _ action: TestAction<T, U>) rethrows -> U {
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        customFormatter.timeZone = TimeZone(identifier: "GMT")
        
        let formatter = Formatter(format: .formatter(customFormatter))
        
        return try action(value, formatter)
    }
    
    func test_string_from_value() throws {
        typealias Strings = (
            secondsSince1970: String?,
            millisecondsSince1970: String?,
            iso8601: String?,
            custom: String?
        )
        
        let examples: [(Value, Strings)] = [
            (
                Date(timeIntervalSince1970: 0.0),
                (
                    secondsSince1970: "0.0",
                    millisecondsSince1970: "0.0",
                    iso8601: "1970-01-01T00:00:00Z",
                    custom: "01-01-1970 00:00:00"
                )
            ),
            (
                Date(timeIntervalSince1970: 123_456_789.0),
                (
                    secondsSince1970: "123456789.0",
                    millisecondsSince1970: "123456789000.0",
                    iso8601: "1973-11-29T21:33:09Z",
                    custom: "11-29-1973 21:33:09"
                )
            ),
        ]
        
        let action: TestAction = { value, formatter in
            try formatter.string(from: value)
        }
        
        for (value, expected) in examples {
            if let expected = expected.secondsSince1970 {
                let string: String = try self.withSecondsSince1970Formatter(value, action)
                XCTAssertEqual(string, expected)
            } else {
                XCTAssertThrowsError(try self.withSecondsSince1970Formatter(value, action))
            }
            
            if let expected = expected.millisecondsSince1970 {
                let string: String = try self.withMillisecondsSince1970Formatter(value, action)
                XCTAssertEqual(string, expected)
            } else {
                XCTAssertThrowsError(try self.withMillisecondsSince1970Formatter(value, action))
            }
            
            if let expected = expected.iso8601 {
                let string: String = try self.withIso8601Formatter(value, action)
                XCTAssertEqual(string, expected)
            } else {
                XCTAssertThrowsError(try self.withIso8601Formatter(value, action))
            }
            
            if let expected = expected.custom {
                let string: String = try self.withCustomFormatter(value, action)
                XCTAssertEqual(string, expected)
            } else {
                XCTAssertThrowsError(try self.withCustomFormatter(value, action))
            }
        }
    }
    
    func test_value_from_string() throws {
        typealias Strings = (
            secondsSince1970: String,
            millisecondsSince1970: String,
            iso8601: String,
            custom: String
        )
        
        let examples: [(Strings, Value)] = [
            (
                (
                    secondsSince1970: "0.0",
                    millisecondsSince1970: "0.0",
                    iso8601: "1970-01-01T00:00:00Z",
                    custom: "01-01-1970 00:00:00"
                ),
                Date(timeIntervalSince1970: 0.0)
            ),
            (
                (
                    secondsSince1970: "123456789.0",
                    millisecondsSince1970: "123456789000.0",
                    iso8601: "1973-11-29T21:33:09Z",
                    custom: "11-29-1973 21:33:09"
                ),
                Date(timeIntervalSince1970: 123_456_789.0)
            ),
        ]
        
        let action: TestAction = { string, formatter in
            try formatter.value(from: string)
        }
        
        for (strings, expected) in examples {
            let secondsSince1970Value: Value = try self.withSecondsSince1970Formatter(strings.secondsSince1970, action)
            XCTAssertEqual(secondsSince1970Value, expected)
            
            let millisecondsSince1970Value: Value = try self.withMillisecondsSince1970Formatter(strings.millisecondsSince1970, action)
            XCTAssertEqual(millisecondsSince1970Value, expected)
            
            let iso8601Value: Value = try self.withIso8601Formatter(strings.iso8601, action)
            XCTAssertEqual(iso8601Value, expected)
            
            let customValue: Value = try self.withCustomFormatter(strings.custom, action)
            XCTAssertEqual(customValue, expected)
        }
    }
    
    func test_value_from_string_invalid() throws {
        typealias Examples = (
            secondsSince1970: [String],
            millisecondsSince1970: [String],
            iso8601: [String],
            custom: [String]
        )
        
        let strings = [
            "",
            "lorem ipsum",
        ]
        
        let examples: Examples = (
            secondsSince1970: strings,
            millisecondsSince1970: strings,
            iso8601: strings,
            custom: strings
        )
        
        let action: TestAction = { string, formatter in
            try formatter.value(from: string)
        }
        
        for string in examples.secondsSince1970 {
            XCTAssertThrowsError(try self.withSecondsSince1970Formatter(string, action))
        }
        
        for string in examples.millisecondsSince1970 {
            XCTAssertThrowsError(try self.withMillisecondsSince1970Formatter(string, action))
        }
        
        for string in examples.iso8601 {
            XCTAssertThrowsError(try self.withIso8601Formatter(string, action))
        }
        
        for string in examples.custom {
            XCTAssertThrowsError(try self.withCustomFormatter(string, action))
        }
    }
}
