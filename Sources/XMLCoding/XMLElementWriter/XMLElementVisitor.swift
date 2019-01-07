//
//  XMLElementVisitor.swift
//  XMLCoding
//
//  Created by Vincent Esche on 1/5/19.
//

import Foundation

public protocol XMLElementVisitor {
    func enter(document: XMLDocument) throws
    func exitDocument() throws
    
    func enter(element: XMLElementNodeInfo, attributes: [String: String]?) throws
    func exit(element: XMLElementNodeInfo) throws
    
    func visit(element: XMLElementNodeInfo, attributes: [String: String]?) throws

    func visit(string: String) throws
    func visit(data: Data) throws
}
