import XCTest
@testable import XMLDocument
@testable import XMLReader

class XMLReaderTests: XCTestCase {
    func test_read_invalid_string() throws {
        let reader = XMLReader()
        
        // Invalid UTF-8 byte sequence:
        let xmlData = Data(bytes: [0x80, 0xBF])
        
        XCTAssertThrowsError(
            try {
                let _: XMLDocumentNode = try reader.read(from: xmlData)
            }()
        )
    }
    
    func test_read_invalid_xml() throws {
        let reader = XMLReader()
        
        // Invalid XML string (invalid use of meta-chararacter `&`):
        let xmlString =
"""
<container>
lorem ipsum & dolor sit amet
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        XCTAssertThrowsError(
            try {
                let _: XMLDocumentNode = try reader.read(from: xmlData)
            }()
        )
    }
    
    func test_read_empty() throws {
        let reader = XMLReader()
        
        let xmlString =
"""
<container attribute="ATTRIBUTE">
    <!-- EMPTY -->
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        let document: XMLDocumentNode = try reader.read(from: xmlData)
        let element = document.rootElement
        
        XCTAssertEqual(element.info.name, "container")
        XCTAssertEqual(element.attributes, ["attribute": "ATTRIBUTE"])
        XCTAssertTrue(element.content.isEmpty)
    }
    
    func test_read_string() throws {
        let reader = XMLReader()
        
        let xmlString =
"""
<container attribute="ATTRIBUTE">
    STRING
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        let document: XMLDocumentNode = try reader.read(from: xmlData)
        let element = document.rootElement
        
        XCTAssertEqual(element.info.name, "container")
        XCTAssertEqual(element.attributes, ["attribute": "ATTRIBUTE"])
        XCTAssertEqual(element.content.string, "STRING")
    }
    
    func test_read_data() throws {
        let reader = XMLReader()
        
        let xmlString =
        """
<container attribute="ATTRIBUTE">
    <![CDATA[DATA]]>
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        let document: XMLDocumentNode = try reader.read(from: xmlData)
        let element = document.rootElement
        
        XCTAssertEqual(element.info.name, "container")
        XCTAssertEqual(element.attributes, ["attribute": "ATTRIBUTE"])
        XCTAssertEqual(element.content.data, "DATA".data(using: .utf8)!)
    }
    
    func test_read_complex() throws {
        let reader = XMLReader()
        
        let xmlString =
        """
<container attribute="ATTRIBUTE">
    <foo />
    <bar />
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        let document: XMLDocumentNode = try reader.read(from: xmlData)
        let element = document.rootElement
        
        XCTAssertEqual(element.info.name, "container")
        XCTAssertEqual(element.attributes, ["attribute": "ATTRIBUTE"])
        XCTAssertEqual(element.content.elements, [
            XMLElementNode.empty(name: "foo"),
            XMLElementNode.empty(name: "bar"),
        ])
    }
    
    func test_read_mixed() throws {
        let reader = XMLReader()
        
        let xmlString =
        """
<container attribute="ATTRIBUTE">
    foo
    <bar />
    <![CDATA[DATA]]>
</container>
"""
        let xmlData = xmlString.data(using: .utf8)!
        
        let document: XMLDocumentNode = try reader.read(from: xmlData)
        let element = document.rootElement
        
        XCTAssertEqual(element.info.name, "container")
        XCTAssertEqual(element.attributes, ["attribute": "ATTRIBUTE"])
        XCTAssertEqual(element.content.items, [
            .string("foo"),
            .element(.empty(name: "bar")),
            .data("DATA".data(using: .utf8)!),
        ])
    }
    
    func test_read_deep() throws {
        let reader = XMLReader()
        
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
        
        let document: XMLDocumentNode = try reader.read(from: xmlData)
        let element = document.rootElement
        
        XCTAssertEqual(element.info.name, "container")
        XCTAssertEqual(element.attributes, ["attribute": "ATTRIBUTE"])
        XCTAssertEqual(element.content.items, [
            .string("foo"),
            .element(.complex(name: "bar", elements: [
                XMLElementNode.empty(name: "baz"),
            ])),
            .data("DATA".data(using: .utf8)!),
        ])
    }
}
