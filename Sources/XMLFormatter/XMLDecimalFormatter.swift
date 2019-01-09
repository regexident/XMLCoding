import Foundation

public struct XMLDecimalFormatter {
    public typealias Value = Decimal
    
    public enum Error: Swift.Error {
        case invalidValue
        case infinityUnsupported
    }
    
    public init() {}
}

extension XMLDecimalFormatter: XMLFormatter {
    public func value(from string: String) throws -> Value {
        guard string != "INF" else {
            throw Error.infinityUnsupported
        }
        guard string != "-INF" else {
            throw Error.infinityUnsupported
        }
        guard string != "NaN" else {
            return Decimal(.nan)
        }
        guard let value = Value(string: string) else {
            throw Error.invalidValue
        }
        return value
    }
    
    public func string(from value: Value) throws -> String {
        guard !value.isNaN else {
            return "NaN"
        }
        
        // Infinite values aren't yet supported by Decimal (January 2019)
//        guard !value.isInfinite else {
//            return (value > 0.0) ? "INF" : "-INF"
//        }
        
        return "\(value)"
    }
}
