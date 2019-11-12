import Foundation

public enum XMLStringFormatterError: Swift.Error {
    case invalidValue
}

public struct XMLStringFormatter {
    public typealias Value = String
    public typealias Error = XMLStringFormatterError
    
    public init() {}
}

extension XMLStringFormatter: XMLFormatter {
    public func value(from string: String) throws -> Value {
        return string
    }
    
    public func string(from value: Value) throws -> String {
        return value
    }
}
