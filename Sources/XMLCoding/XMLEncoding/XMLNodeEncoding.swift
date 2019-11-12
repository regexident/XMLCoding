import Foundation

/// A node's encoding tyoe
public enum XMLNodeEncoding {
    case attribute
    case element
    
    public static let `default`: XMLNodeEncoding = .element
}
