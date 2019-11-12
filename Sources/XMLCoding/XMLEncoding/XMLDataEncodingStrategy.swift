import Foundation

/// The strategy to use for encoding `Data` values.
public enum XMLDataEncodingStrategy {
    /// Defer to `Data` for choosing an encoding.
    case deferredToData
    
    /// Encoded the `Data` as a Base64-encoded string. This is the default strategy.
    case base64
    
    /// Encode the `Data` as a custom value encoded by the given closure.
    ///
    /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
    case custom((Data, Encoder) throws -> ())
}
