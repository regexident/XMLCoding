//
//  XMLElementWriter+XMLElementVisitor.swift
//  XMLCoding
//
//  Created by Vincent Esche on 1/5/19.
//

import Foundation

extension XMLElementWriter: XMLElementVisitor {
    public func enter(document: XMLDocument) throws {
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
