//
//  XMLElementWriterTests.swift
//  XMLCodingTests
//
//  Created by Vincent Esche on 1/4/19.
//

import XCTest
@testable import XMLCoding

extension OutputStream {
    var inMemoryData: Data? {
        return self.property(forKey: .dataWrittenToMemoryStreamKey) as! Data?
    }
    
    var inMemoryString: String? {
        return self.inMemoryData.flatMap { data in
            return String(data: data, encoding: .utf8)
        }
    }
}

class XMLElementWriterTests: XCTestCase {
    func test_writeStartOfDocument_no_header() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.writeStartOfDocument(header: nil)
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "")
    }
    
    func test_writeStartOfDocument_header_empty() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        let header = XMLDocumentHeader(version: nil, encoding: nil, standalone: nil)
        try writer.writeStartOfDocument(header: header)
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "")
    }
    
    func test_writeStartOfDocument_header_version() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        let header = XMLDocumentHeader(version: "1.0", encoding: nil, standalone: nil)
        try writer.writeStartOfDocument(header: header)
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<?xml version=\"1.0\" ?>")
    }
    
    func test_writeStartOfDocument_header_encoding() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        let header = XMLDocumentHeader(version: nil, encoding: "UTF-8", standalone: nil)
        try writer.writeStartOfDocument(header: header)
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<?xml encoding=\"UTF-8\" ?>")
    }
    
    func test_writeStartOfDocument_header_standalone() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        let header = XMLDocumentHeader(version: nil, encoding: nil, standalone: "yes")
        try writer.writeStartOfDocument(header: header)
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<?xml standalone=\"yes\" ?>")
    }
    
    func test_writeStartOfDocument_header_version_encoding_standalone() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        let header = XMLDocumentHeader(version: "1.0", encoding: "UTF-8", standalone: "yes")
        try writer.writeStartOfDocument(header: header)
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>")
    }
    
    func test_writeEndOfDocument() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)

        try writer.writeEndOfDocument()

        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "")
    }
    
    func test_write_processingInstruction() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(
            processingInstruction: XMLProcessingInstruction(
                target: "foo",
                value: "bar"
            )
        )
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<?foo bar?>")
    }
    
    func test_write_comment() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(comment: "lorem & ipsum")
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<!-- lorem &amp; ipsum -->")
    }
    
    func test_write_whitespace() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(whitespace: "\t\t\t")
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "\t\t\t")
    }
    
    func test_write_string() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(string: "lorem & ipsum")
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "lorem &amp; ipsum")
    }
    
    func test_write_data() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(data: "lorem & ipsum".data(using: .utf8)!)
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<![CDATA[lorem & ipsum]]>")
    }
    
    func test_write_element_start() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(start: XMLElementNodeInfo(name: "foo"))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<foo>")
    }
    
    func test_write_element_start_with_attributes() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(
            start: XMLElementNodeInfo(name: "foo"),
            attributes: ["bar": "baz"]
        )
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<foo bar=\"baz\">")
    }
    
    func test_write_element_end() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(end: XMLElementNodeInfo(name: "foo"))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "</foo>")
    }
    
    func test_write_element_empty() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(empty: XMLElementNodeInfo(name: "foo"))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<foo/>")
    }
    
    func test_write_element_empty_with_attributes() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(
            empty: XMLElementNodeInfo(name: "foo"),
            attributes: ["bar": "baz"]
        )
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<foo bar=\"baz\"/>")
    }
    
    func test_write_fragment_empty() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(fragment: .empty(
            name: "foo"
        ))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<foo/>")
    }
    
    func test_write_fragment_simple_string() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(fragment: .string(
            name: "foo",
            string: "BLEE"
        ))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<foo>BLEE</foo>")
    }
    
    func test_write_fragment_simple_data() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(fragment: .data(
            name: "foo",
            data: "blee".data(using: .utf8)!
        ))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<foo><![CDATA[blee]]></foo>")
    }
    
    func test_write_fragment_complex() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(fragment: .complex(
            name: "foo",
            elements: [
                .string(name: "bar", string: "baz"),
                .empty(name: "blee"),
            ]
        ))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<foo><bar>baz</bar><blee/></foo>")
    }
    
    func test_write_fragment_mixed() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(fragment: .mixed(
            name: "foo",
            items: [
                .string("bar"),
                .element(.empty(name: "baz")),
                .data("blee".data(using: .utf8)!),

            ]
        ))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<foo>bar<baz/><![CDATA[blee]]></foo>")
    }
    
    func test_write_fragment_deep() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(fragment: .mixed(
            name: "foo",
            items: [
                .string("bar"),
                .element(.mixed(name: "baz", items: [
                    .data("blee".data(using: .utf8)!),
                ])),
            ]
        ))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<foo>bar<baz><![CDATA[blee]]></baz></foo>")
    }
    
    func test_write_document_exceeding_stream_memory() throws {
        var buffer: [UInt8] = []
        let stream = OutputStream(toBuffer: &buffer, capacity: 0)
        let writer = XMLElementWriter(stream: stream)
        
        // This is expected to fail as the buffer doesn't have any capacity:
        XCTAssertThrowsError(
            try writer.write(document: XMLCoding.XMLDocument(
                header: nil,
                rootElement: .empty(
                    name: "foo"
                )
            ))
        )
    }
    
    func test_write_document_exceeding_stream_memory_2() throws {
        var buffer: [UInt8] = [42, 42, 42, 42, 42, 42]
        let stream = OutputStream(toBuffer: &buffer, capacity: 6)
        let writer = XMLElementWriter(stream: stream)
        
        // This is expected to fail as the buffer doesn't have any capacity:
//        XCTAssertThrowsError(
            try writer.write(document: XMLCoding.XMLDocument(
                header: nil,
                rootElement: .empty(
                    name: "foo"
                )
            ))
//        )
    }
    
    func test_write_document_empty() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(document: XMLCoding.XMLDocument(
            header: nil,
            rootElement: .empty(
                name: "foo"
            )
        ))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<foo/>")
    }
    
    func test_write_document_empty_with_header() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(document: XMLCoding.XMLDocument(
            header: XMLDocumentHeader(version: "1.0", encoding: "UTF-8"),
            rootElement: .empty(
                name: "foo"
            )
        ))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString,
"""
<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\
<foo/>
"""
)
    }
    
    func test_write_document_deep() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(document: XMLCoding.XMLDocument(
            header: nil,
            rootElement: .mixed(
                name: "foo",
                items: [
                    .string("bar"),
                    .element(.mixed(name: "baz", items: [
                        .data("blee".data(using: .utf8)!),
                    ])),
                ]
            )
        ))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString, "<foo>bar<baz><![CDATA[blee]]></baz></foo>")
    }
    
    func test_write_document_deep_with_header() throws {
        let stream = OutputStream.toMemory()
        let writer = XMLElementWriter(stream: stream)
        
        try writer.write(document: XMLCoding.XMLDocument(
            header: XMLDocumentHeader(version: "1.0", encoding: "UTF-8"),
            rootElement: .mixed(
                name: "foo",
                items: [
                    .string("bar"),
                    .element(.mixed(name: "baz", items: [
                        .data("blee".data(using: .utf8)!),
                    ])),
                ]
            )
        ))
        
        let xmlString = stream.inMemoryString!
        XCTAssertEqual(xmlString,
"""
<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\
<foo>bar<baz><![CDATA[blee]]></baz></foo>
"""
        )
    }
}
