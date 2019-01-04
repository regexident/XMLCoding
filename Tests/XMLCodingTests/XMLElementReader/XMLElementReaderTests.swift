//
//  XMLElementReaderTests.swift
//  ests
//
//  Created by Vincent Esche on 1/3/19.
//  Copyright © 2019 Vincent Esche. All rights reserved.
//

import XCTest
@testable import XMLCoding

class XMLElementReaderTests: XCTestCase {
    func test_parse_invalid_string() throws {
        let reader = XMLElementReader()
        
        // Invalid UTF8 byte sequence:
        let xmlData = Data(bytes: [0x80, 0xBF])
        
        XCTAssertThrowsError(try reader.read(from: xmlData))
    }
    
    func test_parse_invalid_xml() throws {
        let reader = XMLElementReader()
        
        // Invalid XML string (invalid use of meta-chararacter `&`):
        let xmlString =
"""
<container>
lorem ipsum & dolor sit amet
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        XCTAssertThrowsError(try reader.read(from: xmlData))
    }
    
    func test_parse_empty() throws {
        let reader = XMLElementReader()
        
        let xmlString =
"""
<container attribute="ATTRIBUTE">
    <!-- EMPTY -->
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        let element = try reader.read(from: xmlData)
        
        XCTAssertEqual(element.key, "container")
        XCTAssertEqual(element.attributes, ["attribute": "ATTRIBUTE"])
        XCTAssertTrue(element.content.isEmpty)
    }
    
    func test_parse_string() throws {
        let reader = XMLElementReader()
        
        let xmlString =
"""
<container attribute="ATTRIBUTE">
    STRING
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        let element = try reader.read(from: xmlData)
        
        XCTAssertEqual(element.key, "container")
        XCTAssertEqual(element.attributes, ["attribute": "ATTRIBUTE"])
        XCTAssertEqual(element.content.string, "STRING")
    }
    
    func test_parse_data() throws {
        let reader = XMLElementReader()
        
        let xmlString =
        """
<container attribute="ATTRIBUTE">
    <![CDATA[DATA]]>
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        let element = try reader.read(from: xmlData)
        
        XCTAssertEqual(element.key, "container")
        XCTAssertEqual(element.attributes, ["attribute": "ATTRIBUTE"])
        XCTAssertEqual(element.content.data, "DATA".data(using: .utf8)!)
    }
    
    func test_parse_complex() throws {
        let reader = XMLElementReader()
        
        let xmlString =
        """
<container attribute="ATTRIBUTE">
    <foo />
    <bar />
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        let element = try reader.read(from: xmlData)
        
        XCTAssertEqual(element.key, "container")
        XCTAssertEqual(element.attributes, ["attribute": "ATTRIBUTE"])
        XCTAssertEqual(element.content.elements, [
            XMLElementNode.empty(key: "foo"),
            XMLElementNode.empty(key: "bar"),
        ])
    }
    
    func test_parse_mixed() throws {
        let reader = XMLElementReader()
        
        let xmlString =
        """
<container attribute="ATTRIBUTE">
    foo
    <bar />
    <![CDATA[DATA]]>
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        let element = try reader.read(from: xmlData)
        
        XCTAssertEqual(element.key, "container")
        XCTAssertEqual(element.attributes, ["attribute": "ATTRIBUTE"])
        XCTAssertEqual(element.content.items, [
            .string("foo"),
            .element(.empty(key: "bar")),
            .data("DATA".data(using: .utf8)!),
        ])
    }
    
    func test_parse_deep() throws {
        let reader = XMLElementReader()
        
        let xmlString =
        """
<container attribute="ATTRIBUTE">
    foo
    <bar>
        <baz />
    </bar>
    <![CDATA[DATA]]>
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        let element = try reader.read(from: xmlData)
        
        XCTAssertEqual(element.key, "container")
        XCTAssertEqual(element.attributes, ["attribute": "ATTRIBUTE"])
        XCTAssertEqual(element.content.items, [
            .string("foo"),
            .element(.complex(key: "bar", elements: [
                XMLElementNode.empty(key: "baz"),
            ])),
            .data("DATA".data(using: .utf8)!),
        ])
    }
}
