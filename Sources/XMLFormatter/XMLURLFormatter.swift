import Foundation

public struct XMLURLFormatter {
    public typealias Value = URL
    
    public enum Error: Swift.Error {
        case invalidValue
    }
    
    public init() {}
}

extension XMLURLFormatter: XMLFormatter {
    public func value(from string: String) throws -> Value {
        guard let value = Value(string: string) else {
            throw Error.invalidValue
        }
        return value
    }
    
    public func string(from value: Value) throws -> String {
        return value.absoluteString
    }
}
