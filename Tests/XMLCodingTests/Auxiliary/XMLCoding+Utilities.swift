import Foundation

struct XMLCodingPathFormatter {
    func string(from codingPath: [CodingKey]) -> String {
        return codingPath.map {
            ($0.intValue != nil) ? "\($0.intValue!)" : $0.stringValue
        }.joined(separator: ".")
    }
}

enum CodingPathError: Swift.Error {
    case unexpectedCodingPath(expected: String, found: String)
    
    var localizedDescription: String {
        switch self {
        case .unexpectedCodingPath(expected: let expected, found: let found):
            return "Expected '\(expected)', found '\(found)'."
        }
    }
}

func XCTAssertEqualCodingPath(_ found: [CodingKey], _ expected: [CodingKey]) throws {
    let formatter = XMLCodingPathFormatter()
    
    let expectedString = formatter.string(from: expected)
    let foundString = formatter.string(from: found)
    
    if !expected.isEmpty, foundString != expectedString {
        print("Expected '\(expectedString)', found '\(foundString)'.")
        throw CodingPathError.unexpectedCodingPath(expected: expectedString, found: foundString)
    }
}
