import Foundation

public protocol FixedWidthFloatingPoint: Comparable, ExpressibleByFloatLiteral {
    var isNaN: Bool { get }
    var isInfinite: Bool { get }
    
    init?<S>(_ text: S) where S: StringProtocol
}

extension Float: FixedWidthFloatingPoint {
    // Required methods are already provided by Float
}

extension Double: FixedWidthFloatingPoint {
    // Required methods are already provided by Float
}

public struct XMLFloatingPointFormatter<T: FixedWidthFloatingPoint> {
    public typealias Value = T
    
    public enum Error: Swift.Error {
        case invalidValue
    }
    
    public init() {}
}

extension XMLFloatingPointFormatter: XMLFormatter {
    public func value(from string: String) throws -> Value {
        guard let value = Value(string) else {
            throw Error.invalidValue
        }
        return value
    }
    
    public func string(from value: Value) throws -> String {
        guard !value.isNaN else {
            return "NaN"
        }
        
        guard !value.isInfinite else {
            return (value > 0.0) ? "INF" : "-INF"
        }
        
        return "\(value)"
    }
}

public typealias XMLFloatFormatter = XMLFloatingPointFormatter<Float>
public typealias XMLDoubleFormatter = XMLFloatingPointFormatter<Double>

public typealias XMLFloat32Formatter = XMLFloatFormatter
public typealias XMLFloat64Formatter = XMLDoubleFormatter
