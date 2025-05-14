import XCTest

@testable import XMLDocument
@testable import XMLWriter

class XMLWriterTests: XCTestCase {
    typealias TestAction = (XMLWriter) throws -> ()
    
    func withCompactWriter(_ action: TestAction) rethrows -> String {
        let stream = OutputStream.toMemory()
        let writer = XMLWriter(stream: stream, formatting: .compact)
        
        try action(writer)
        
        return stream.inMemoryString!
    }
    
    func withSpaceIndentedWriter(_ action: TestAction) rethrows -> String {
        let stream = OutputStream.toMemory()
        let writer = XMLWriter(stream: stream, formatting: .prettyPrinted(.spaces(4)))
        
        try action(writer)
        
        return stream.inMemoryString!
    }
    
    func withTabIndentedWriter(_ action: TestAction) rethrows -> String {
        let stream = OutputStream.toMemory()
        let writer = XMLWriter(stream: stream, formatting: .prettyPrinted(.tabs))
        
        try action(writer)
        
        return stream.inMemoryString!
    }
    
    func test_writeStartOfDocument_no_header() throws {
        let action: TestAction = { writer in
            try writer.writeStartOfDocument(header: nil)
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "")
    }
    
    func test_writeStartOfDocument_header_none() throws {
        let action: TestAction = { writer in
            let header = XMLDocumentHeader(version: nil, encoding: nil, standalone: nil)
            try writer.writeStartOfDocument(header: header)
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "")
    }
    
    func test_writeStartOfDocument_header_version() throws {
        let action: TestAction = { writer in
            let header = XMLDocumentHeader(version: "1.0", encoding: nil, standalone: nil)
            try writer.writeStartOfDocument(header: header)
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<?xml version=\"1.0\" ?>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<?xml version=\"1.0\" ?>\n")
    }
    
    func test_writeStartOfDocument_header_encoding() throws {
        let action: TestAction = { writer in
            let header = XMLDocumentHeader(version: nil, encoding: "UTF-8", standalone: nil)
            try writer.writeStartOfDocument(header: header)
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<?xml encoding=\"UTF-8\" ?>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<?xml encoding=\"UTF-8\" ?>\n")
    }
    
    func test_writeStartOfDocument_header_standalone() throws {
        let action: TestAction = { writer in
            let header = XMLDocumentHeader(version: nil, encoding: nil, standalone: "yes")
            try writer.writeStartOfDocument(header: header)
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<?xml standalone=\"yes\" ?>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<?xml standalone=\"yes\" ?>\n")
    }
    
    func test_writeStartOfDocument_header_all() throws {
        let action: TestAction = { writer in
            let header = XMLDocumentHeader(version: "1.0", encoding: "UTF-8", standalone: "yes")
            try writer.writeStartOfDocument(header: header)
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>\n")
    }
    
    func test_writeEndOfDocument() throws {
        let action: TestAction = { writer in
            try writer.writeEndOfDocument()
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "")
    }
    
    func test_write_processingInstruction() throws {
        let action: TestAction = { writer in
            try writer.write(
                processingInstruction: XMLProcessingInstruction(
                    target: "foo",
                    value: "bar"
                )
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<?foo bar?>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<?foo bar?>\n")
    }
    
    func test_write_comment() throws {
        let action: TestAction = { writer in
            try writer.write(comment: "lorem & ipsum")
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<!-- lorem &amp; ipsum -->")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<!-- lorem &amp; ipsum -->\n")
    }
    
    func test_write_whitespace() throws {
        let action: TestAction = { writer in
            try writer.write(whitespace: "\t\t\t")
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "\t\t\t")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "\t\t\t")
    }
    
    func test_write_string() throws {
        let action: TestAction = { writer in
            try writer.write(string: "lorem & ipsum")
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "lorem &amp; ipsum")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "lorem &amp; ipsum\n")
    }
    
    func test_write_data() throws {
        let action: TestAction = { writer in
            try writer.write(data: "lorem & ipsum".data(using: .utf8)!)
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<![CDATA[lorem & ipsum]]>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<![CDATA[lorem & ipsum]]>\n")
    }
    
    func test_write_element_start() throws {
        let action: TestAction = { writer in
            try writer.write(start: XMLElementNodeInfo(name: "foo"))
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<foo>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<foo>\n")
    }
    
    func test_write_element_start_with_attributes() throws {
        let action: TestAction = { writer in
            try writer.write(
                start: XMLElementNodeInfo(name: "foo"),
                attributes: ["bar": "baz"]
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<foo bar=\"baz\">")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<foo bar=\"baz\">\n")
    }
    
    func test_write_element_end() throws {
        let action: TestAction = { writer in
            try writer.write(end: XMLElementNodeInfo(name: "foo"))
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "</foo>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "</foo>\n")
    }
    
    func test_write_element_empty() throws {
        let action: TestAction = { writer in
            try writer.write(empty: XMLElementNodeInfo(name: "foo"))
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<foo/>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<foo/>\n")
    }
    
    func test_write_element_empty_with_attributes() throws {
        let action: TestAction = { writer in
            try writer.write(
                empty: XMLElementNodeInfo(name: "foo"),
                attributes: ["bar": "baz"]
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<foo bar=\"baz\"/>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<foo bar=\"baz\"/>\n")
    }
    
    func test_write_fragment_empty() throws {
        let action: TestAction = { writer in
            try writer.write(
                fragment: .empty(
                    name: "foo"
                )
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<foo/>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<foo/>\n")
    }
    
    func test_write_fragment_simple_string() throws {
        let action: TestAction = { writer in
            try writer.write(
                fragment: .string(
                    name: "foo",
                    string: "bar"
                )
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<foo>bar</foo>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<foo>bar</foo>\n")
    }
    
    func test_write_fragment_simple_data() throws {
        let action: TestAction = { writer in
            try writer.write(
                fragment: .data(
                    name: "foo",
                    data: "bar".data(using: .utf8)!
                )
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<foo><![CDATA[bar]]></foo>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<foo><![CDATA[bar]]></foo>\n")
    }
    
    func test_write_fragment_complex() throws {
        let action: TestAction = { writer in
            try writer.write(
                fragment: .complex(
                    name: "foo",
                    elements: [
                        .string(name: "bar", string: "baz"),
                        .empty(name: "blee"),
                    ]
                )
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<foo><bar>baz</bar><blee/></foo>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(
            spaceIndented,
            """
            <foo>
                <bar>baz</bar>
                <blee/>
            </foo>
                
            """
        )
    }
    
    func test_write_fragment_mixed() throws {
        let action: TestAction = { writer in
            try writer.write(
                fragment: .mixed(
                    name: "foo",
                    items: [
                        .string("bar"),
                        .element(.empty(name: "baz")),
                        .data("blee".data(using: .utf8)!),
                    ]
                )
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<foo>bar<baz/><![CDATA[blee]]></foo>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(
            spaceIndented,
            """
            <foo>
                bar
                <baz/>
                <![CDATA[blee]]>
            </foo>
                
            """
        )
    }
    
    func test_write_fragment_deep() throws {
        let action: TestAction = { writer in
            try writer.write(
                fragment: .complex(
                    name: "foo",
                    elements: [
                        .mixed(
                            name: "bar", items: [
                                .string("baz"),
                                .data("blee".data(using: .utf8)!),
                            ]
                        ),
                    ]
                )
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<foo><bar>baz<![CDATA[blee]]></bar></foo>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(
            spaceIndented,
            """
            <foo>
                <bar>
                    baz
                    <![CDATA[blee]]>
                </bar>
            </foo>
                
            """
        )
    }
    
    func test_write_document_exceeding_stream_memory() throws {
        var buffer: [UInt8] = []
        let stream = OutputStream(toBuffer: &buffer, capacity: 0)
        let writer = XMLWriter(stream: stream)
        
        // This is expected to fail as the buffer doesn't have any capacity:
        XCTAssertThrowsError(
            try writer.write(
                document: XMLDocumentNode(
                    header: nil,
                    rootElement: .empty(
                        name: "foo"
                    )
                )
            )
        )
    }
    
    func test_write_document_empty() throws {
        let action: TestAction = { writer in
            try writer.write(
                document: XMLDocumentNode(
                    header: nil,
                    rootElement: .empty(
                        name: "foo"
                    )
                )
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(compact, "<foo/>")
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(spaceIndented, "<foo/>\n")
    }
    
    func test_write_document_empty_with_header() throws {
        let action: TestAction = { writer in
            try writer.write(
                document: XMLDocumentNode(
                    header: XMLDocumentHeader(version: "1.0", encoding: "UTF-8"),
                    rootElement: .empty(
                        name: "foo"
                    )
                )
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(
            compact,
            """
            <?xml version=\"1.0\" encoding=\"UTF-8\" ?>\
            <foo/>
            """
        )
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(
            spaceIndented,
            """
            <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
            <foo/>
                
            """
        )
    }
    
    func test_write_document_deep() throws {
        let action: TestAction = { writer in
            try writer.write(
                document: XMLDocumentNode(
                    header: nil,
                    rootElement: .complex(
                        name: "foo",
                        elements: [
                            .mixed(
                                name: "bar", items: [
                                    .string("baz"),
                                    .data("blee".data(using: .utf8)!),
                                ]
                            ),
                        ]
                    )
                )
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(
            compact,
            """
            <foo><bar>baz<![CDATA[blee]]></bar></foo>
            """
        )
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(
            spaceIndented,
            """
            <foo>
                <bar>
                    baz
                    <![CDATA[blee]]>
                </bar>
            </foo>
                
            """
        )
    }
    
    func test_write_document_deep_with_header() throws {
        let action: TestAction = { writer in
            try writer.write(
                document: XMLDocumentNode(
                    header: XMLDocumentHeader(version: "1.0", encoding: "UTF-8"),
                    rootElement: .complex(
                        name: "foo",
                        elements: [
                            .mixed(
                                name: "bar", items: [
                                    .string("baz"),
                                    .data("blee".data(using: .utf8)!),
                                ]
                            ),
                        ]
                    )
                )
            )
        }
        
        let compact = try self.withCompactWriter(action)
        XCTAssertEqual(
            compact,
            """
            <?xml version=\"1.0\" encoding=\"UTF-8\" ?>\
            <foo><bar>baz<![CDATA[blee]]></bar></foo>
            """
        )
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(
            spaceIndented,
            """
            <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
            <foo>
                <bar>
                    baz
                    <![CDATA[blee]]>
                </bar>
            </foo>
                
            """
        )
    }
    
    func test_write_tab_indentation() throws {
        let action: TestAction = { writer in
            try writer.write(
                fragment: .complex(
                    name: "foo",
                    elements: [
                        .empty(name: "bar"),
                    ]
                )
            )
        }
        
        let spaceIndented = try self.withSpaceIndentedWriter(action)
        XCTAssertEqual(
            spaceIndented,
            """
            <foo>
                <bar/>
            </foo>
                
            """
        )
        
        let tabIndented = try self.withTabIndentedWriter(action)
        XCTAssertEqual(
            tabIndented,
            """
            <foo>
            	<bar/>
            </foo>
                
            """
        )
    }
    
    static var allTests = [
        ("test_writeStartOfDocument_no_header", test_writeStartOfDocument_no_header),
        ("test_writeStartOfDocument_header_none", test_writeStartOfDocument_header_none),
        ("test_writeStartOfDocument_header_version", test_writeStartOfDocument_header_version),
        ("test_writeStartOfDocument_header_encoding", test_writeStartOfDocument_header_encoding),
        ("test_writeStartOfDocument_header_standalone", test_writeStartOfDocument_header_standalone),
        ("test_writeStartOfDocument_header_all", test_writeStartOfDocument_header_all),
        ("test_writeEndOfDocument", test_writeEndOfDocument),
        ("test_write_processingInstruction", test_write_processingInstruction),
        ("test_write_comment", test_write_comment),
        ("test_write_whitespace", test_write_whitespace),
        ("test_write_string", test_write_string),
        ("test_write_data", test_write_data),
        ("test_write_element_start", test_write_element_start),
        ("test_write_element_start_with_attributes", test_write_element_start_with_attributes),
        ("test_write_element_end", test_write_element_end),
        ("test_write_element_empty", test_write_element_empty),
        ("test_write_element_empty_with_attributes", test_write_element_empty_with_attributes),
        ("test_write_fragment_empty", test_write_fragment_empty),
        ("test_write_fragment_simple_string", test_write_fragment_simple_string),
        ("test_write_fragment_simple_data", test_write_fragment_simple_data),
        ("test_write_fragment_complex", test_write_fragment_complex),
        ("test_write_fragment_mixed", test_write_fragment_mixed),
        ("test_write_fragment_deep", test_write_fragment_deep),
        ("test_write_document_exceeding_stream_memory", test_write_document_exceeding_stream_memory),
        ("test_write_document_empty", test_write_document_empty),
        ("test_write_document_empty_with_header", test_write_document_empty_with_header),
        ("test_write_document_deep", test_write_document_deep),
        ("test_write_document_deep_with_header", test_write_document_deep_with_header),
        ("test_write_tab_indentation", test_write_tab_indentation),
    ]
}
