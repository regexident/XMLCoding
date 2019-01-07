import Foundation

public struct XMLDocumentHeader {
    public let version: String?
    
    public let encoding: String?
    
    public let standalone: String?
    
    public static let `default`: XMLDocumentHeader = .init(
        version: "1.0",
        encoding: "UTF-8"
    )
    
    public init(version: String? = nil, encoding: String? = nil, standalone: String? = nil) {
        self.version = version
        self.encoding = encoding
        self.standalone = standalone
    }
    
    public var isEmpty: Bool {
        guard self.version == nil else {
            return false
        }
        guard self.encoding == nil else {
            return false
        }
        guard self.standalone == nil else {
            return false
        }
        return true
    }
}
