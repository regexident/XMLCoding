import Foundation

/// The strategy to use for encoding `Date` values.
public enum XMLDateEncodingStrategy {
    /// Defer to `Date` for choosing an encoding. This is the default strategy.
    case deferredToDate
    
    /// Encode the `Date` as a UNIX timestamp (as a XML number).
    case secondsSince1970
    
    /// Encode the `Date` as UNIX millisecond timestamp (as a XML number).
    case millisecondsSince1970
    
    /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    case iso8601
    
    /// Encode the `Date` as a string formatted by the given formatter.
    case formatted(DateFormatter)
    
    /// Encode the `Date` as a custom value encoded by the given closure.
    ///
    /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
    case custom((Date, Encoder) throws -> ())
}
