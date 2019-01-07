import Foundation

import XMLDocument

extension XMLWriter: XMLVisitor {
    public func enter(document: XMLDocumentNode) throws {
        try self.writeStartOfDocument(header: document.header)
    }
    
    public func exitDocument() throws {
        try self.writeEndOfDocument()
    }
    
    public func enter(element: XMLElementNodeInfo, attributes: [String: String]?) throws {
        try self.write(start: element, attributes: attributes)
    }
    
    public func exit(element: XMLElementNodeInfo) throws {
        try self.write(end: element)
    }
    
    public func visit(element: XMLElementNodeInfo, attributes: [String: String]?) throws {
        try self.write(empty: element, attributes: attributes)
    }
    
    public func visit(string: String) throws {
        try self.write(string: string)
    }
    
    public func visit(data: Data) throws {
        try self.write(data: data)
    }
}
