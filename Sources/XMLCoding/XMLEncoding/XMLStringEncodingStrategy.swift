import Foundation

/// The strategy to use for encoding `String` values.
public enum XMLStringEncodingStrategy {
    /// Defer to `String` for choosing an encoding. This is the default strategy.
    case deferredToString
    
    /// Encoded the `String` as a CData-encoded string.
    case cdata
}
