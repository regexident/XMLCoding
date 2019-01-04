//
//  XMLMixedContent.swift
//  XMLCoding
//
//  Created by Vincent Esche on 1/3/19.
//  Copyright © 2019 Vincent Esche. All rights reserved.
//

import Foundation

struct XMLMixedContent: Equatable {
    var items: [XMLMixedContentItem] = []
}

enum XMLMixedContentItem: Equatable {
    case string(String)
    case data(Data)
    case element(XMLElementNode)
    
    var string: String? {
        guard case let .string(string) = self else {
            return nil
        }
        return string
    }
    
    var data: Data? {
        guard case let .data(data) = self else {
            return nil
        }
        return data
    }
    
    var element: XMLElementNode? {
        guard case let .element(element) = self else {
            return nil
        }
        return element
    }
    
    init(simple: XMLSimpleContent) {
        switch simple {
        case .string(let string):
            self = .string(string)
        case .data(let data):
            self = .data(data)
        }
    }
}
