import XCTest
@testable import XMLDocument

class XMLElementNodeTests: XCTestCase {
    let elementName: String = "foo"
    let attributes: [String: String] = ["bar": "baz"]
    let content: XMLElementNodeContent = .empty(XMLEmptyContent())
}

// MARK: - Initialize elements

extension XMLElementNodeTests {
    func test_init_info() {
        let subject = XMLElementNode(
            name: elementName,
            attributes: attributes,
            content: content
        )

        XCTAssertEqual(subject.info.name, elementName)
        XCTAssertEqual(subject.attributes, attributes)
        XCTAssertEqual(subject.content, content)
    }

    func test_init_name() {
        let subject = XMLElementNode(
            name: elementName,
            attributes: attributes,
            content: content
        )

        XCTAssertEqual(subject.info.name, elementName)
        XCTAssertEqual(subject.attributes, attributes)
        XCTAssertEqual(subject.content, content)
    }

    func test_empty() {
        let subject = XMLElementNode.empty(name: elementName)

        XCTAssertNotNil(subject.content.isEmpty)
    }

    func test_string() {
        let subject = XMLElementNode.string(name: elementName, string: "foo")

        XCTAssertTrue(subject.content.isSimple)
    }

    func test_data() {
        let subject = XMLElementNode.data(name: elementName, data: "foo".data(using: .utf8)!)

        XCTAssertTrue(subject.content.isSimple)
    }

    func test_complex() {
        let subject = XMLElementNode.complex(name: elementName, elements: [])

        XCTAssertTrue(subject.content.isComplex)
    }

    func test_mixed() {
        let subject = XMLElementNode.mixed(name: elementName, items: [])

        XCTAssertTrue(subject.content.isMixed)
    }

    func test_equal() {
        XCTAssertEqual(
            XMLElementNode(
                name: "foo",
                attributes: ["bar": "baz"],
                content: .simple(.string("blee"))
            ),
            XMLElementNode(
                name: "foo",
                attributes: ["bar": "baz"],
                content: .simple(.string("blee"))
            )
        )

        XCTAssertNotEqual(
            XMLElementNode(
                name: "foo",
                attributes: ["bar": "baz"],
                content: .simple(.string("blee"))
            ),
            XMLElementNode(
                name: "!!!",
                attributes: ["bar": "baz"],
                content: .simple(.string("blee"))
            )
        )

        XCTAssertNotEqual(
            XMLElementNode(
                name: "foo",
                attributes: ["bar": "baz"],
                content: .simple(.string("blee"))
            ),
            XMLElementNode(
                name: "foo",
                attributes: ["!!!": "baz"],
                content: .simple(.string("blee"))
            )
        )

        XCTAssertNotEqual(
            XMLElementNode(
                name: "foo",
                attributes: ["bar": "baz"],
                content: .simple(.string("blee"))
            ),
            XMLElementNode(
                name: "foo",
                attributes: ["bar": "!!!"],
                content: .simple(.string("blee"))
            )
        )

        XCTAssertNotEqual(
            XMLElementNode(
                name: "foo",
                attributes: ["bar": "baz"],
                content: .simple(.string("blee"))
            ),
            XMLElementNode(
                name: "foo",
                attributes: ["bar": "baz"],
                content: .simple(.string("!!!"))
            )
        )

        XCTAssertNotEqual(
            XMLElementNode(
                name: "foo",
                attributes: ["bar": "baz"],
                content: .simple(.string("blee"))
            ),
            XMLElementNode(
                name: "!!!",
                attributes: ["!!!": "!!!"],
                content: .simple(.string("!!!"))
            )
        )
    }
}

// MARK: - Append to elements

extension XMLElementNodeTests {
    // MARK: - Append to element

    func test_append_with_string() {
        let string = "foo"

        let subject = XMLElementNode(
            name: elementName,
            attributes: attributes,
            content: self.content
        )

        var content = subject.content

        subject.append(string: string)
        content.append(string: string)

        XCTAssertEqual(subject.content, content)
    }

    func test_append_with_data() {
        let data = "foo".data(using: .utf8)!

        let subject = XMLElementNode(
            name: elementName,
            attributes: attributes,
            content: self.content
        )

        var content = subject.content

        subject.append(data: data)
        content.append(data: data)

        XCTAssertEqual(subject.content, content)
    }

    func test_append_with_element() {
        let element = XMLElementNode(
            name: elementName,
            attributes: attributes,
            content: .empty(XMLEmptyContent())
        )

        let subject = XMLElementNode(
            name: elementName,
            attributes: attributes,
            content: self.content
        )

        var content = element.content

        subject.append(element: element)
        content.append(element: element)

        XCTAssertEqual(subject.content, content)
    }

    static var allTests = [
        ("test_init_info", test_init_info),
        ("test_init_name", test_init_name),
        ("test_empty", test_empty),
        ("test_string", test_string),
        ("test_data", test_data),
        ("test_complex", test_complex),
        ("test_mixed", test_mixed),
        ("test_append_with_string", test_append_with_string),
        ("test_append_with_data", test_append_with_data),
        ("test_append_with_element", test_append_with_element),
    ]
}
