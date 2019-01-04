//
//  XMLElementNode.swift
//  XMLCoding
//
//  Created by Vincent Esche on 1/3/19.
//  Copyright © 2019 Vincent Esche. All rights reserved.
//

import Foundation

struct XMLElementNode: Equatable {
    var key: String
    var attributes: [String: String]
    var content: XMLElementNodeContent
    
    static func empty(key: String, attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            key: key,
            attributes: attributes,
            content: .empty(XMLEmptyContent())
        )
    }
    
    static func string(key: String, string: String, attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            key: key,
            attributes: attributes,
            content: .simple(.string(string))
        )
    }
    
    static func data(key: String, data: Data, attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            key: key,
            attributes: attributes,
            content: .simple(.data(data))
        )
    }
    
    static func complex(key: String, elements: [XMLElementNode], attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            key: key,
            attributes: attributes,
            content: .complex(XMLComplexContent(elements: elements))
        )
    }
    
    static func mixed(key: String, items: [XMLMixedContentItem], attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            key: key,
            attributes: attributes,
            content: .mixed(XMLMixedContent(items: items))
        )
    }
    
    mutating func append(string: String) {
        self.content.append(string: string)
    }
    
    mutating func append(data: Data) {
        self.content.append(data: data)
    }
    
    mutating func append(element: XMLElementNode) {
        self.content.append(element: element)
    }
}
