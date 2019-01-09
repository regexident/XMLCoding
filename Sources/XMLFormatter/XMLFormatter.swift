import Foundation

public protocol XMLFormatter {
    associatedtype Value
    
    func value(from string: String) throws -> Value
    func string(from value: Value) throws -> String
}
