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
    
    public func visit(element: XMLElementNodeInfo, content: XMLSimpleContent?, attributes: [String: String]?) throws {
        guard let content = content else {
            return try self.write(empty: element, attributes: attributes)
        }
        
        let collapsingThreshold = 50
        
        switch content {
        case .string(let string):
            let collapsed = string.count < collapsingThreshold
            try self.write(start: element, attributes: attributes, collapsed: collapsed)
            try self.write(string: string, collapsed: collapsed)
            try self.write(end: element, collapsed: collapsed)
        case .data(let data):
            let collapsed = data.count < collapsingThreshold
            try self.write(start: element, attributes: attributes, collapsed: collapsed)
            try self.write(data: data, collapsed: collapsed)
            try self.write(end: element, collapsed: collapsed)
        }
    }
    
    public func visit(string: String) throws {
        try self.write(string: string)
    }
    
    public func visit(data: Data) throws {
        try self.write(data: data)
    }
}
