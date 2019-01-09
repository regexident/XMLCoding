import Foundation

public struct XMLDateFormatter {
    public typealias Value = Date
    
    public enum Error: Swift.Error {
        case invalidValue
    }
    
    public enum Format: Equatable {
        case secondsSince1970
        case millisecondsSince1970
        case iso8601
        case formatter(DateFormatter)
        
        public static let `default`: Format = .iso8601
    }
    
    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    fileprivate static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    
    public let format: Format
    
    public init(format: Format = .default) {
        self.format = format
    }
}

extension XMLDateFormatter: XMLFormatter {
    public func value(from string: String) throws -> Value {
        switch self.format {
        case .secondsSince1970:
            return try self.value(fromSecondsSince1970String: string)
        case .millisecondsSince1970:
            return try self.value(fromMillisecondsSince1970String: string)
        case .iso8601:
            return try self.value(fromIso8601String: string)
        case .formatter(let formatter):
            return try self.value(from: string, with: formatter)
        }
    }
    
    public func string(from value: Value) throws -> String {
        switch self.format {
        case .secondsSince1970:
            return try self.secondsSince1970String(from: value)
        case .millisecondsSince1970:
            return try self.millisecondsSince1970String(from: value)
        case .iso8601:
            return try self.iso8601String(from: value)
        case .formatter(let formatter):
            return try self.string(from: value, with: formatter)
        }
    }
}

extension XMLDateFormatter {
    fileprivate func secondsSince1970String(from value: Value) throws -> String {
        let seconds = value.timeIntervalSince1970
        
        return "\(seconds)"
    }
    
    fileprivate func millisecondsSince1970String(from value: Value) throws -> String {
        let millisecondsPerSecond = 1000.0
        
        let seconds = value.timeIntervalSince1970
        
        let milliseconds = seconds * millisecondsPerSecond
        
        return "\(milliseconds)"
    }
    
    fileprivate func iso8601String(from value: Value) throws -> String {
        if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            let formatter = XMLDateFormatter.iso8601Formatter
            
            let value = formatter.string(from: value)
            
            return value
        } else {
            fatalError("ISO8601DateFormatter is unavailable on this platform.")
        }
    }
    
    fileprivate func string(from value: Value, with formatter: DateFormatter) throws -> String {
        let string = formatter.string(from: value)
        
        return string
    }
    
    fileprivate func value(fromSecondsSince1970String string: String) throws -> Value {
        guard let seconds = TimeInterval(string) else {
            throw Error.invalidValue
        }
        
        let value = Value(timeIntervalSince1970: seconds)
        
        return value
    }
    
    fileprivate func value(fromMillisecondsSince1970String string: String) throws -> Value {
        guard let milliseconds = TimeInterval(string) else {
            throw Error.invalidValue
        }
        
        let millisecondsPerSecond = 1000.0
        
        let seconds = milliseconds / millisecondsPerSecond
        
        let value = Value(timeIntervalSince1970: seconds)
        
        return value
    }
    
    fileprivate func value(fromIso8601String string: String) throws -> Value {
        if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            let formatter = XMLDateFormatter.iso8601Formatter
            
            guard let value = formatter.date(from: string) else {
                throw Error.invalidValue
            }
            
            return value
        } else {
            fatalError("ISO8601DateFormatter is unavailable on this platform.")
        }
    }
    
    fileprivate func value(from string: String, with formatter: DateFormatter) throws -> Value {
        guard let value = formatter.date(from: string) else {
            throw Error.invalidValue
        }
        
        return value
    }
}
