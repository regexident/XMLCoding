import Foundation

/// The formatting of the output XML data.
public struct XMLOutputFormatting: OptionSet {
    /// The format's default value.
    public let rawValue: UInt
    
    /// Creates an OutputFormatting value with the given raw value.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    /// Produce human-readable XML with indented output.
    public static let prettyPrinted = XMLOutputFormatting(rawValue: 1 << 0)
    
    /// Produce XML with keys sorted in lexicographic order.
    public static let sortedKeys = XMLOutputFormatting(rawValue: 1 << 1)
}
