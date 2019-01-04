//
//  XMLElementNodeTests.swift
//  XMLCodingTests
//
//  Created by Vincent Esche on 1/3/19.
//  Copyright © 2019 Vincent Esche. All rights reserved.
//

import XCTest
@testable import XMLCoding

class XMLElementNodeTests: XCTestCase {
    let key: String = "foo"
    let attributes: [String: String] = ["bar": "baz"]
    let content: XMLElementNodeContent = .empty(XMLEmptyContent())
    
    func element() -> XMLElementNode {
        return XMLElementNode(
            key: self.key,
            attributes: self.attributes,
            content: self.content
        )
    }
}

// MARK: - Initialize elements
extension XMLElementNodeTests {
    func test_init() {
        let subject = self.element()
        
        XCTAssertEqual(subject.key, self.key)
        XCTAssertEqual(subject.attributes, self.attributes)
        XCTAssertEqual(subject.content, self.content)
    }
    
    func test_empty() {
        let subject = XMLElementNode.empty(key: self.key)
        
        XCTAssertTrue(subject.content.isEmpty)
    }
    
    func test_string() {
        let subject = XMLElementNode.string(key: self.key, string: "foo")
        
        XCTAssertTrue(subject.content.isSimple)
    }
    
    func test_data() {
        let subject = XMLElementNode.data(key: self.key, data: "foo".data(using: .utf8)!)
        
        XCTAssertTrue(subject.content.isSimple)
    }
    
    func test_complex() {
        let subject = XMLElementNode.complex(key: self.key, elements: [])
        
        XCTAssertTrue(subject.content.isComplex)
    }
    
    func test_mixed() {
        let subject = XMLElementNode.mixed(key: self.key, items: [])
        
        XCTAssertTrue(subject.content.isMixed)
    }
}

// MARK: - Append to elements
extension XMLElementNodeTests {
    // MARK: - Append to element
    
    func test_append_with_string() {
        let string = "foo"
        
        var subject = self.element()
        var content = subject.content
        
        subject.append(string: string)
        content.append(string: string)
        
        XCTAssertEqual(subject.content, content)
    }
    
    func test_append_with_data() {
        let data = "foo".data(using: .utf8)!
        
        var subject = self.element()
        var content = subject.content
        
        subject.append(data: data)
        content.append(data: data)
        
        XCTAssertEqual(subject.content, content)
    }
    
    func test_append_with_element() {
        let element = XMLElementNode(
            key: self.key,
            attributes: self.attributes,
            content: .empty(XMLEmptyContent())
        )
        
        var subject = self.element()
        var content = element.content
        
        subject.append(element: element)
        content.append(element: element)
        
        XCTAssertEqual(subject.content, content)
    }
}
