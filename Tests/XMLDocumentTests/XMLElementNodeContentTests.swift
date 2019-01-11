import XCTest
@testable import XMLDocument

class XMLElementNodeContentTests: XCTestCase {
    let elementName: String = "foo"
    let attributes: [String: String] = ["bar": "baz"]

    let string: String = "string"
    lazy var data: Data = "data".data(using: .utf8)!

    func emptyContent() -> XMLElementNodeContent {
        return .empty(XMLEmptyContent())
    }

    func emptyElement() -> XMLElementNode {
        return element(with: emptyContent())
    }

    func stringContent() -> XMLSimpleContent {
        return .string(string)
    }

    func stringContent() -> XMLElementNodeContent {
        return .simple(stringContent())
    }

    func stringElement() -> XMLElementNode {
        return element(with: stringContent())
    }

    func dataContent() -> XMLSimpleContent {
        return .data(data)
    }

    func dataContent() -> XMLElementNodeContent {
        return .simple(dataContent())
    }

    func dataElement() -> XMLElementNode {
        return element(with: dataContent())
    }

    func simpleContent() -> XMLSimpleContent {
        return stringContent()
    }

    func simpleContent() -> XMLElementNodeContent {
        return stringContent()
    }

    func complexContent() -> XMLElementNodeContent {
        return .complex(
            XMLComplexContent(
                elements: [
                    self.emptyElement(),
                    self.stringElement(),
                    self.dataElement(),
                ]
            )
        )
    }

    func mixedContent() -> XMLElementNodeContent {
        return .mixed(
            XMLMixedContent(
                items: [
                    .string(self.string),
                    .data(self.data),
                    .element(self.emptyElement()),
                ]
            )
        )
    }

    func element(with content: XMLElementNodeContent) -> XMLElementNode {
        return XMLElementNode(
            name: elementName,
            attributes: attributes,
            content: content
        )
    }
}

// MARK: - Append to content

extension XMLElementNodeContentTests {
    // MARK: - Append to empty content

    func test_empty() {
        let subject: XMLElementNodeContent = emptyContent()

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
        let subject: XMLElementNodeContent = stringContent()

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
        let subject: XMLElementNodeContent = dataContent()

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
        let subject: XMLElementNodeContent = complexContent()

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
        let subject: XMLElementNodeContent = mixedContent()

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

        var subject: XMLElementNodeContent = emptyContent()

        XCTAssertTrue(subject.isEmpty)

        subject.append(string: string)

        XCTAssertTrue(subject.isSimple)

        XCTAssertEqual(subject.string, string)
    }

    func test_append_empty_with_data() {
        let data = self.data

        var subject: XMLElementNodeContent = emptyContent()

        XCTAssertTrue(subject.isEmpty)

        subject.append(data: data)

        XCTAssertTrue(subject.isSimple)

        XCTAssertEqual(subject.data, data)
    }

    func test_append_empty_with_element() {
        let element = emptyElement()

        var subject: XMLElementNodeContent = emptyContent()

        XCTAssertTrue(subject.isEmpty)

        subject.append(element: element)

        let elements = [element]

        XCTAssertTrue(subject.isComplex)

        XCTAssertEqual(subject.elements, elements)
    }

    // MARK: - Append to string content

    func test_append_string_with_string() {
        let string = self.string

        var subject: XMLElementNodeContent = stringContent()

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

        var subject: XMLElementNodeContent = stringContent()

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
        let element = emptyElement()

        var subject: XMLElementNodeContent = stringContent()

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

        var subject: XMLElementNodeContent = dataContent()

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

        var subject: XMLElementNodeContent = dataContent()

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
        let element = emptyElement()

        var subject: XMLElementNodeContent = dataContent()

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

        var subject: XMLElementNodeContent = complexContent()

        XCTAssertTrue(subject.isComplex)

        var items: [XMLMixedContentItem] = subject.elements!.map { .element($0) }
        items += [.string(string)]

        subject.append(string: string)

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    func test_append_complex_with_data() {
        let data = self.data

        var subject: XMLElementNodeContent = complexContent()

        XCTAssertTrue(subject.isComplex)

        var items: [XMLMixedContentItem] = subject.elements!.map { .element($0) }
        items += [.data(data)]

        subject.append(data: data)

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    func test_append_complex_with_element() {
        let element = emptyElement()

        var subject: XMLElementNodeContent = complexContent()

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

        var subject: XMLElementNodeContent = mixedContent()

        XCTAssertTrue(subject.isMixed)

        var items = subject.items!
        items += [.string(string)]

        subject.append(string: string)

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    func test_append_mixed_with_data() {
        let data = self.data

        var subject: XMLElementNodeContent = mixedContent()

        XCTAssertTrue(subject.isMixed)

        var items = subject.items!
        items += [.data(data)]

        subject.append(data: data)

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    func test_append_mixed_with_element() {
        let element = emptyElement()

        var subject: XMLElementNodeContent = mixedContent()

        XCTAssertTrue(subject.isMixed)

        var items = subject.items!
        items += [.element(element)]

        subject.append(element: element)

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }
}

// MARK: - Insert into content

extension XMLElementNodeContentTests {
    // MARK: - Insert into empty content

    func test_insert_empty_with_string() {
        let string = self.string

        var subject: XMLElementNodeContent = emptyContent()

        XCTAssertTrue(subject.isEmpty)

        subject.insert(string: string, at: 0)

        XCTAssertTrue(subject.isSimple)

        XCTAssertEqual(subject.string, string)
    }

    func test_insert_empty_with_data() {
        let data = self.data

        var subject: XMLElementNodeContent = emptyContent()

        XCTAssertTrue(subject.isEmpty)

        subject.insert(data: data, at: 0)

        XCTAssertTrue(subject.isSimple)

        XCTAssertEqual(subject.data, data)
    }

    func test_insert_empty_with_element() {
        let element = emptyElement()

        var subject: XMLElementNodeContent = emptyContent()

        XCTAssertTrue(subject.isEmpty)

        subject.insert(element: element, at: 0)

        let elements = [element]

        XCTAssertTrue(subject.isComplex)

        XCTAssertEqual(subject.elements, elements)
    }

    // MARK: - Insert into string content

    func test_insert_string_with_string() {
        let string = self.string

        var subject: XMLElementNodeContent = stringContent()

        XCTAssertTrue(subject.isSimple)

        subject.insert(string: string, at: 0)

        let items = [
            XMLMixedContentItem(simple: self.stringContent()),
            .string(string),
        ]

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    func test_insert_string_with_data() {
        let data = self.data

        var subject: XMLElementNodeContent = stringContent()

        XCTAssertTrue(subject.isSimple)

        subject.insert(data: data, at: 1)

        let items = [
            XMLMixedContentItem(simple: self.stringContent()),
            .data(data),
        ]

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    func test_insert_string_with_element() {
        let element = emptyElement()

        var subject: XMLElementNodeContent = stringContent()

        XCTAssertTrue(subject.isSimple)

        subject.insert(element: element, at: 1)

        let items = [
            XMLMixedContentItem(simple: self.stringContent()),
            .element(element),
        ]

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    // MARK: - Insert into data content

    func test_insert_data_with_string() {
        let string = self.string

        var subject: XMLElementNodeContent = dataContent()

        XCTAssertTrue(subject.isSimple)

        subject.insert(string: string, at: 1)

        let items = [
            XMLMixedContentItem(simple: self.dataContent()),
            .string(string),
        ]

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    func test_insert_data_with_data() {
        let data = self.data

        var subject: XMLElementNodeContent = dataContent()

        XCTAssertTrue(subject.isSimple)

        subject.insert(data: data, at: 1)

        let items = [
            XMLMixedContentItem(simple: self.dataContent()),
            .data(data),
        ]

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    func test_insert_data_with_element() {
        let element = emptyElement()

        var subject: XMLElementNodeContent = dataContent()

        XCTAssertTrue(subject.isSimple)

        subject.insert(element: element, at: 1)

        let items = [
            XMLMixedContentItem(simple: self.dataContent()),
            .element(element),
        ]

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    // MARK: - Insert into complex content

    func test_insert_complex_with_string() {
        let string = self.string

        var subject: XMLElementNodeContent = complexContent()

        XCTAssertTrue(subject.isComplex)

        var items: [XMLMixedContentItem] = subject.elements!.map { .element($0) }
        items += [.string(string)]

        subject.insert(string: string, at: 3)

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    func test_insert_complex_with_data() {
        let data = self.data

        var subject: XMLElementNodeContent = complexContent()

        XCTAssertTrue(subject.isComplex)

        var items: [XMLMixedContentItem] = subject.elements!.map { .element($0) }
        items += [.data(data)]

        subject.insert(data: data, at: 3)

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    func test_insert_complex_with_element() {
        let element = emptyElement()

        var subject: XMLElementNodeContent = complexContent()

        XCTAssertTrue(subject.isComplex)

        var elements = subject.elements!
        elements += [element]

        subject.insert(element: element, at: 3)

        XCTAssertTrue(subject.isComplex)

        XCTAssertEqual(subject.elements, elements)
    }

    // MARK: - Insert into mixed content

    func test_insert_mixed_with_string() {
        let string = self.string

        var subject: XMLElementNodeContent = mixedContent()

        XCTAssertTrue(subject.isMixed)

        var items = subject.items!
        items += [.string(string)]

        subject.insert(string: string, at: 3)

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    func test_insert_mixed_with_data() {
        let data = self.data

        var subject: XMLElementNodeContent = mixedContent()

        XCTAssertTrue(subject.isMixed)

        var items = subject.items!
        items += [.data(data)]

        subject.insert(data: data, at: 3)

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }

    func test_insert_mixed_with_element() {
        let element = emptyElement()

        var subject: XMLElementNodeContent = mixedContent()

        XCTAssertTrue(subject.isMixed)

        var items = subject.items!
        items += [.element(element)]

        subject.insert(element: element, at: 3)

        XCTAssertTrue(subject.isMixed)

        XCTAssertEqual(subject.items, items)
    }
}

extension XMLElementNodeContentTests {
    static var allTests = [
        ("test_empty", test_empty),
        ("test_string", test_string),
        ("test_data", test_data),
        ("test_complex", test_complex),
        ("test_mixed", test_mixed),
        ("test_append_empty_with_string", test_append_empty_with_string),
        ("test_append_empty_with_data", test_append_empty_with_data),
        ("test_append_empty_with_element", test_append_empty_with_element),
        ("test_append_string_with_string", test_append_string_with_string),
        ("test_append_string_with_data", test_append_string_with_data),
        ("test_append_string_with_element", test_append_string_with_element),
        ("test_append_data_with_string", test_append_data_with_string),
        ("test_append_data_with_data", test_append_data_with_data),
        ("test_append_data_with_element", test_append_data_with_element),
        ("test_append_complex_with_string", test_append_complex_with_string),
        ("test_append_complex_with_data", test_append_complex_with_data),
        ("test_append_complex_with_element", test_append_complex_with_element),
        ("test_append_mixed_with_string", test_append_mixed_with_string),
        ("test_append_mixed_with_data", test_append_mixed_with_data),
        ("test_append_mixed_with_element", test_append_mixed_with_element),
        ("test_insert_empty_with_string", test_insert_empty_with_string),
        ("test_insert_empty_with_data", test_insert_empty_with_data),
        ("test_insert_empty_with_element", test_insert_empty_with_element),
        ("test_insert_string_with_string", test_insert_string_with_string),
        ("test_insert_string_with_data", test_insert_string_with_data),
        ("test_insert_string_with_element", test_insert_string_with_element),
        ("test_insert_data_with_string", test_insert_data_with_string),
        ("test_insert_data_with_data", test_insert_data_with_data),
        ("test_insert_data_with_element", test_insert_data_with_element),
        ("test_insert_complex_with_string", test_insert_complex_with_string),
        ("test_insert_complex_with_data", test_insert_complex_with_data),
        ("test_insert_complex_with_element", test_insert_complex_with_element),
        ("test_insert_mixed_with_string", test_insert_mixed_with_string),
        ("test_insert_mixed_with_data", test_insert_mixed_with_data),
        ("test_insert_mixed_with_element", test_insert_mixed_with_element),
    ]
}
