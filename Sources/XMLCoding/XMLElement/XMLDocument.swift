//
//  XMLDocument.swift
//  XMLCoding
//
//  Created by Vincent Esche on 1/7/19.
//

import Foundation

public struct XMLDocument {
    let header: XMLDocumentHeader?
    public let rootElement: XMLElementNode
    
    public func accept<T: XMLElementVisitor>(visitor: T) throws {
        try visitor.enter(document: self)
        try self.rootElement.accept(visitor: visitor)
        try visitor.exitDocument()
    }
}
