import Foundation

public enum XMLFormatterError: Swift.Error {
    case invalidStringEncoding
}

public protocol XMLFormatter {
    associatedtype Value
    
    func value(from string: String) throws -> Value
    func string(from value: Value) throws -> String
}

extension XMLFormatter {
    public func data(from value: Value, encoding: String.Encoding = .utf8) throws -> Data {
        let string = try self.string(from: value)
        
        guard let data = string.data(using: encoding) else {
            throw XMLFormatterError.invalidStringEncoding
        }
        
        return data
    }
    
    public func value(from data: Data, encoding: String.Encoding = .utf8) throws -> Value {
        guard let string = String(data: data, encoding: encoding) else {
            throw XMLFormatterError.invalidStringEncoding
        }
        
        return try self.value(from: string)
    }
}
