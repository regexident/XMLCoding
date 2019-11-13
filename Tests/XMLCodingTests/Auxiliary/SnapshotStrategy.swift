import Foundation

import SnapshotTesting

@testable import XMLCoding

extension Snapshotting where Value: Encodable, Format == String {
    public static var defaultXMLRootKey: String {
        return "root"
    }
    
    /// A snapshot strategy for comparing encodable structures based on their XML representation.
    @available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
    public static func xml(
        rootKey: String = Snapshotting.defaultXMLRootKey
    ) -> Snapshotting {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return .xml(encoder)
    }
    
    /// A snapshot strategy for comparing encodable structures based on their XML representation.
    ///
    /// - Parameter encoder: A XML encoder.
    public static func xml(
        rootKey: String = Snapshotting.defaultXMLRootKey,
        _ encoder: XMLEncoder
    ) -> Snapshotting {
        var snapshotting = SimplySnapshotting.lines.pullback { (encodable: Value) in
            let data = try! encoder.encode(encodable, rootKey: rootKey)
            return String(decoding: data, as: UTF8.self)
        }
        snapshotting.pathExtension = "xml"
        return snapshotting
    }
}
