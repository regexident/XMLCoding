import Foundation

public protocol XMLCustomNodeEncodable {
    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding
}
