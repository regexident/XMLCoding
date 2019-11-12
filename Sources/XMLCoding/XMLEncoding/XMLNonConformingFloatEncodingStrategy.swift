import Foundation

/// The strategy to use for non-XML-conforming floating-point values (IEEE 754 infinity and NaN).
public enum XMLNonConformingFloatEncodingStrategy {
    /// Throw upon encountering non-conforming values. This is the default strategy.
    case `throw`
    
    /// Encode the values using the given representation strings.
    case convertToString(positiveInfinity: String, negativeInfinity: String, nan: String)
}
