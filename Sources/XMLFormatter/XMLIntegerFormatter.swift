import Foundation

public struct XMLIntegerFormatter<T: FixedWidthInteger> {
    public typealias Value = T
    
    public enum Error: Swift.Error {
        case invalidValue
    }
}

extension XMLIntegerFormatter: XMLFormatter {
    public func value(from string: String) throws -> Value {
        guard let value = Value(string) else {
            throw Error.invalidValue
        }
        return value
    }
    
    public func string(from value: Value) throws -> String {
        return "\(value)"
    }
}

public typealias XMLInt8Formatter = XMLIntegerFormatter<Int8>
public typealias XMLInt16Formatter = XMLIntegerFormatter<Int16>
public typealias XMLInt32Formatter = XMLIntegerFormatter<Int32>
public typealias XMLInt64Formatter = XMLIntegerFormatter<Int64>
public typealias XMLIntFormatter = XMLIntegerFormatter<Int>

public typealias XMLUInt8Formatter = XMLIntegerFormatter<UInt8>
public typealias XMLUInt16Formatter = XMLIntegerFormatter<UInt16>
public typealias XMLUInt32Formatter = XMLIntegerFormatter<UInt32>
public typealias XMLUInt64Formatter = XMLIntegerFormatter<UInt64>
public typealias XMLUIntFormatter = XMLIntegerFormatter<UInt>
