//
//  XMLElementNodeContentTests.swift
//  XMLCodingTests
//
//  Created by Vincent Esche on 1/3/19.
//  Copyright © 2019 Vincent Esche. All rights reserved.
//

import XCTest
@testable import XMLCoding

extension XMLElementNodeContent {
    var string: String? {
        guard case .simple(.string(let string)) = self else {
            return nil
        }
        return string
    }
    
    var data: Data? {
        guard case .simple(.data(let data)) = self else {
            return nil
        }
        return data
    }
    
    var elements: [XMLElementNode]? {
        guard case .complex(let content) = self else {
            return nil
        }
        return content.elements
    }
    
    var items: [XMLMixedContentItem]? {
        guard case .mixed(let content) = self else {
            return nil
        }
        return content.items
    }
}

class XMLElementNodeContentTests: XCTestCase {
    let elementName: String = "foo"
    let attributes: [String: String] = ["bar": "baz"]
    
    let string: String = "string"
    lazy var data: Data = "data".data(using: .utf8)!
    
    func emptyContent() -> XMLElementNodeContent {
        return .empty(XMLEmptyContent())
    }
    
    func emptyElement() -> XMLElementNode {
        return self.element(with: self.emptyContent())
    }
    
    func stringContent() -> XMLSimpleContent {
        return .string(self.string)
    }
    
    func stringContent() -> XMLElementNodeContent {
        return .simple(self.stringContent())
    }
    
    func stringElement() -> XMLElementNode {
        return self.element(with: self.stringContent())
    }
    
    func dataContent() -> XMLSimpleContent {
        return .data(self.data)
    }
    
    func dataContent() -> XMLElementNodeContent {
        return .simple(self.dataContent())
    }
    
    func dataElement() -> XMLElementNode {
        return self.element(with: self.dataContent())
    }
    
    func simpleContent() -> XMLSimpleContent {
        return self.stringContent()
    }
    
    func simpleContent() -> XMLElementNodeContent {
        return self.stringContent()
    }
    
    func complexContent() -> XMLElementNodeContent {
        return .complex(XMLComplexContent(elements: [
            self.emptyElement(),
            self.stringElement(),
            self.dataElement(),
        ]))
    }
    
    func mixedContent() -> XMLElementNodeContent {
        return .mixed(XMLMixedContent(items: [
            .string(self.string),
            .data(self.data),
            .element(self.emptyElement()),
        ]))
    }
    
    func element(with content: XMLElementNodeContent) -> XMLElementNode {
        return XMLElementNode(
            info: XMLElementNodeInfo(name: self.elementName),
            attributes: self.attributes,
            content: content
        )
    }
}

// MARK: - Append to content
extension XMLElementNodeContentTests {
    // MARK: - Append to empty content
    
    func test_empty() {
        let subject: XMLElementNodeContent = self.emptyContent()
        
        XCTAssertTrue(subject.isEmpty)
        XCTAssertFalse(subject.isSimple)
        XCTAssertFalse(subject.isComplex)
        XCTAssertFalse(subject.isMixed)
        
        XCTAssertNil(subject.string)
        XCTAssertNil(subject.data)
        XCTAssertNil(subject.elements)
        XCTAssertNil(subject.items)
    }
    
    func test_string() {
        let subject: XMLElementNodeContent = self.stringContent()
        
        XCTAssertFalse(subject.isEmpty)
        XCTAssertTrue(subject.isSimple)
        XCTAssertFalse(subject.isComplex)
        XCTAssertFalse(subject.isMixed)
        
        XCTAssertNotNil(subject.string)
        XCTAssertNil(subject.data)
        XCTAssertNil(subject.elements)
        XCTAssertNil(subject.items)
    }
    
    func test_data() {
        let subject: XMLElementNodeContent = self.dataContent()
        
        XCTAssertFalse(subject.isEmpty)
        XCTAssertTrue(subject.isSimple)
        XCTAssertFalse(subject.isComplex)
        XCTAssertFalse(subject.isMixed)
        
        XCTAssertNil(subject.string)
        XCTAssertNotNil(subject.data)
        XCTAssertNil(subject.elements)
        XCTAssertNil(subject.items)
    }
    
    func test_complex() {
        let subject: XMLElementNodeContent = self.complexContent()
        
        XCTAssertFalse(subject.isEmpty)
        XCTAssertFalse(subject.isSimple)
        XCTAssertTrue(subject.isComplex)
        XCTAssertFalse(subject.isMixed)
        
        XCTAssertNil(subject.string)
        XCTAssertNil(subject.data)
        XCTAssertNotNil(subject.elements)
        XCTAssertNil(subject.items)
    }
    
    func test_mixed() {
        let subject: XMLElementNodeContent = self.mixedContent()
        
        XCTAssertFalse(subject.isEmpty)
        XCTAssertFalse(subject.isSimple)
        XCTAssertFalse(subject.isComplex)
        XCTAssertTrue(subject.isMixed)
        
        XCTAssertNil(subject.string)
        XCTAssertNil(subject.data)
        XCTAssertNil(subject.elements)
        XCTAssertNotNil(subject.items)
    }
}

// MARK: - Append to content
extension XMLElementNodeContentTests {
    // MARK: - Append to empty content
    
    func test_append_empty_with_string() {
        let string = self.string
        
        var subject: XMLElementNodeContent = self.emptyContent()
        
        XCTAssertTrue(subject.isEmpty)
        
        subject.append(string: string)
        
        XCTAssertTrue(subject.isSimple)
        
        XCTAssertEqual(subject.string, string)
    }
    
    func test_append_empty_with_data() {
        let data = self.data
        
        var subject: XMLElementNodeContent = self.emptyContent()
        
        XCTAssertTrue(subject.isEmpty)
        
        subject.append(data: data)
        
        XCTAssertTrue(subject.isSimple)
        
        XCTAssertEqual(subject.data, data)
    }
    
    func test_append_empty_with_element() {
        let element = self.emptyElement()
        
        var subject: XMLElementNodeContent = self.emptyContent()
        
        XCTAssertTrue(subject.isEmpty)
        
        subject.append(element: element)
        
        let elements = [element]
        
        XCTAssertTrue(subject.isComplex)
        
        XCTAssertEqual(subject.elements, elements)
    }

    // MARK: - Append to string content
    
    func test_append_string_with_string() {
        let string = self.string

        var subject: XMLElementNodeContent = self.stringContent()
        
        XCTAssertTrue(subject.isSimple)
        
        subject.append(string: string)

        let items = [
            XMLMixedContentItem(simple: self.stringContent()),
            .string(string),
        ]

        XCTAssertTrue(subject.isMixed)
        
        XCTAssertEqual(subject.items, items)
    }
    
    func test_append_string_with_data() {
        let data = self.data

        var subject: XMLElementNodeContent = self.stringContent()
        
        XCTAssertTrue(subject.isSimple)
        
        subject.append(data: data)
        
        let items = [
            XMLMixedContentItem(simple: self.stringContent()),
            .data(data),
        ]

        XCTAssertTrue(subject.isMixed)
        
        XCTAssertEqual(subject.items, items)
    }

    func test_append_string_with_element() {
        let element = self.emptyElement()

        var subject: XMLElementNodeContent = self.stringContent()
        
        XCTAssertTrue(subject.isSimple)
        
        subject.append(element: element)
        
        let items = [
            XMLMixedContentItem(simple: self.stringContent()),
            .element(element),
        ]

        XCTAssertTrue(subject.isMixed)
        
        XCTAssertEqual(subject.items, items)
    }
    
    // MARK: - Append to data content
    
    func test_append_data_with_string() {
        let string = self.string
        
        var subject: XMLElementNodeContent = self.dataContent()
        
        XCTAssertTrue(subject.isSimple)
        
        subject.append(string: string)
        
        let items = [
            XMLMixedContentItem(simple: self.dataContent()),
            .string(string),
        ]
        
        XCTAssertTrue(subject.isMixed)
        
        XCTAssertEqual(subject.items, items)
    }
    
    func test_append_data_with_data() {
        let data = self.data
        
        var subject: XMLElementNodeContent = self.dataContent()
        
        XCTAssertTrue(subject.isSimple)
        
        subject.append(data: data)
        
        let items = [
            XMLMixedContentItem(simple: self.dataContent()),
            .data(data),
        ]
        
        XCTAssertTrue(subject.isMixed)
        
        XCTAssertEqual(subject.items, items)
    }
    
    func test_append_data_with_element() {
        let element = self.emptyElement()
        
        var subject: XMLElementNodeContent = self.dataContent()
        
        XCTAssertTrue(subject.isSimple)
        
        subject.append(element: element)
        
        let items = [
            XMLMixedContentItem(simple: self.dataContent()),
            .element(element),
        ]
        
        XCTAssertTrue(subject.isMixed)
        
        XCTAssertEqual(subject.items, items)
    }
    
    // MARK: - Append to complex content
    
    func test_append_complex_with_string() {
        let string = self.string

        var subject: XMLElementNodeContent = self.complexContent()
        
        XCTAssertTrue(subject.isComplex)
        
        var items: [XMLMixedContentItem] = subject.elements!.map { .element($0) }
        items += [.string(string)]
        
        subject.append(string: string)
        
        XCTAssertTrue(subject.isMixed)
        
        XCTAssertEqual(subject.items, items)
    }

    func test_append_complex_with_data() {
        let data = self.data

        var subject: XMLElementNodeContent = self.complexContent()
        
        XCTAssertTrue(subject.isComplex)
        
        var items: [XMLMixedContentItem] = subject.elements!.map { .element($0) }
        items += [.data(data)]
        
        subject.append(data: data)
        
        XCTAssertTrue(subject.isMixed)
        
        XCTAssertEqual(subject.items, items)
    }

    func test_append_complex_with_element() {
        let element = self.emptyElement()

        var subject: XMLElementNodeContent = self.complexContent()

        XCTAssertTrue(subject.isComplex)
        
        var elements = subject.elements!
        elements += [element]

        subject.append(element: element)

        XCTAssertTrue(subject.isComplex)
        
        XCTAssertEqual(subject.elements, elements)
    }
    
    // MARK: - Append to mixed content
    
    func test_append_mixed_with_string() {
        let string = self.string
        
        var subject: XMLElementNodeContent = self.mixedContent()
        
        XCTAssertTrue(subject.isMixed)
        
        var items = subject.items!
        items += [.string(string)]
        
        subject.append(string: string)
        
        XCTAssertTrue(subject.isMixed)
        
        XCTAssertEqual(subject.items, items)
    }
    
    func test_append_mixed_with_data() {
        let data = self.data

        var subject: XMLElementNodeContent = self.mixedContent()

        XCTAssertTrue(subject.isMixed)
        
        var items = subject.items!
        items += [.data(data)]

        subject.append(data: data)

        XCTAssertTrue(subject.isMixed)
        
        XCTAssertEqual(subject.items, items)
    }

    func test_append_mixed_with_element() {
        let element = self.emptyElement()

        var subject: XMLElementNodeContent = self.mixedContent()

        XCTAssertTrue(subject.isMixed)
        
        var items = subject.items!
        items += [.element(element)]

        subject.append(element: element)

        XCTAssertTrue(subject.isMixed)
        
        XCTAssertEqual(subject.items, items)
    }
}
