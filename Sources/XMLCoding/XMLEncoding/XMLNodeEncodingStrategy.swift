import Foundation

/// Set of strategies to use for encoding of nodes.
public enum XMLNodeEncodingStrategy {
    /// Defer to `Encoder` for choosing an encoding. This is the default strategy.
    case deferredToEncoder
    
    /// Return a closure computing the desired node encoding for the value by its coding key.
    case custom((Encodable.Type, Encoder) -> ((CodingKey) -> XMLEncoder.NodeEncoding))
    
    func nodeEncodings(
        forType codableType: Encodable.Type,
        with encoder: Encoder
    ) -> ((CodingKey) -> XMLEncoder.NodeEncoding) {
        switch self {
        case .deferredToEncoder:
            guard let customNodeEncodable = codableType as? XMLCustomNodeEncodable.Type else {
                return { _ in .default }
            }
            return customNodeEncodable.nodeEncoding(for:)
        case .custom(let closure):
            return closure(codableType, encoder)
        }
    }
}
