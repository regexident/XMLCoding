import Foundation

public enum XMLFormatterError: Error {
    case invalidStringEncoding
}

public protocol XMLFormatter {
    associatedtype Value

    func value(from string: String) throws -> Value
    func string(from value: Value) throws -> String

    func data(from value: Value) throws -> Data
}

extension XMLFormatter {
    public func data(from value: Value) throws -> Data {
        let string = try self.string(from: value)

        guard let data = string.data(using: .utf8) else {
            throw XMLFormatterError.invalidStringEncoding
        }

        return data
    }
}
