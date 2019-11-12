import Foundation

public enum XMLDataFormatterError: Swift.Error {
    case invalidValue
}

public struct XMLDataFormatter {
    public typealias Value = Data
    public typealias Error = XMLDataFormatterError
    
    public enum Format: Equatable {
        case raw
        case base64
        
        public static let `default`: Format = .base64
    }
    
    public let format: Format
    
    public init(format: Format = .default) {
        self.format = format
    }
}

extension XMLDataFormatter: XMLFormatter {
    public func value(from string: String) throws -> Value {
        switch self.format {
        case .raw:
            return try self.value(fromRawString: string)
        case .base64:
            return try self.value(fromBase64String: string)
        }
    }
    
    public func string(from value: Value) throws -> String {
        switch self.format {
        case .raw:
            return try self.rawString(from: value)
        case .base64:
            return try self.base64String(from: value)
        }
    }
}

extension XMLDataFormatter {
    fileprivate func rawString(from value: Value) throws -> String {
        guard let string = String(data: value, encoding: .utf8) else {
            throw Error.invalidValue
        }
        
        return string
    }
    
    fileprivate func base64String(from value: Value) throws -> String {
        let string = value.base64EncodedString()
        
        return string
    }
    
    fileprivate func value(fromRawString string: String) throws -> Value {
        guard let value = string.data(using: .utf8) else {
            throw Error.invalidValue
        }
        
        return value
    }
    
    fileprivate func value(fromBase64String string: String) throws -> Value {
        guard let value = Data(base64Encoded: string) else {
            throw Error.invalidValue
        }
        
        return value
    }
}
