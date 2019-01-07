//
//  XMLElementNode.swift
//  XMLCoding
//
//  Created by Vincent Esche on 1/3/19.
//  Copyright © 2019 Vincent Esche. All rights reserved.
//

import Foundation

class XMLElementReader: NSObject {
    private var stack: [XMLElementNode] = []
    private var error: Error? = nil
    
    func read(from data: Data) throws -> XMLElementNode {
        try XMLParser.parse(data: data, delegate: self)
    
        return self.stack[0]
    }

    func withCurrentElement(_ body: (inout XMLElementNode) throws -> ()) rethrows {
        guard !self.stack.isEmpty else {
            return
        }
        try body(&self.stack[self.stack.count - 1])
    }
}

extension XMLElementReader: XMLParserDelegate {
    func parserDidStartDocument(_: XMLParser) {
        self.stack = []
        self.error = nil
    }

    func parser(_: XMLParser,
                didStartElement elementName: String,
                namespaceURI _: String?,
                qualifiedName _: String?,
                attributes attributeDict: [String: String] = [:]) {
        
        let element = XMLElementNode.empty(
            name: elementName,
            attributes: attributeDict
        )
        self.stack.append(element)
    }

    func parser(_: XMLParser,
        didEndElement _: String,
        namespaceURI _: String?,
        qualifiedName _: String?
    ) {
        if let element = self.stack.popLast() {
            withCurrentElement { currentElement in
                currentElement.append(element: element)
            }
            
            if self.stack.isEmpty {
                self.stack.append(element)
            }
        }
    }

    func parser(_: XMLParser, foundCharacters string: String) {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !string.isEmpty {
            withCurrentElement { currentElement in
                currentElement.append(string: string)
            }
        }
    }

    func parser(_: XMLParser, foundCDATA data: Data) {
        if !data.isEmpty {
            withCurrentElement { currentElement in
                currentElement.append(data: data)
            }
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.error = parseError
//        fatalError("ERROR: \(parseError)")
    }
}
