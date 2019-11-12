import Foundation

public enum XMLBoolFormatterError: Swift.Error {
    case invalidValue
}

public struct XMLBoolFormatter {
    public typealias Value = Bool
    public typealias Error = XMLBoolFormatterError
    
    public init() {}
}

extension XMLBoolFormatter: XMLFormatter {
    public func value(from string: String) throws -> Value {
        switch string {
        case "false", "0": return false
        case "true", "1": return true
        case _:
            throw Error.invalidValue
        }
    }
    
    public func string(from value: Value) throws -> String {
        return (value) ? "true" : "false"
    }
}
