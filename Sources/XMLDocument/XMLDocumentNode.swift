import Foundation

public struct XMLDocumentNode {
    public var header: XMLDocumentHeader?
    public var rootElement: XMLElementNode
    
    public init(
        header: XMLDocumentHeader? = .default,
        rootElement: XMLElementNode
    ) {
        self.header = header
        self.rootElement = rootElement
    }
}

extension XMLDocumentNode: XMLVisitable {
    public typealias Output = ()
    
    public func accept<T: XMLVisitor>(visitor: T) throws -> () {
        try visitor.enter(document: self)
        try self.rootElement.accept(visitor: visitor)
        try visitor.exitDocument()
    }
}
