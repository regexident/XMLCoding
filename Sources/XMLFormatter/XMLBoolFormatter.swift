import Foundation

public struct XMLBoolFormatter {
    public typealias Value = Bool
    
    public enum Error: Swift.Error {
        case invalidValue
    }
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
