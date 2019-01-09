import Foundation

public struct XMLStringFormatter {
    public typealias Value = String
    
    public enum Error: Swift.Error {
        case invalidValue
    }
    
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
