import XCTest
@testable import XMLDocument

class XMLMixedContentTests: XCTestCase {
    func testStringItem() {
        let string = "foo"
        let items: [XMLMixedContentItem] = [
            .string(string),
        ]

        let subject = XMLMixedContent(items: items)

        XCTAssertEqual(subject.items, items)
    }
}

class XMLMixedContentItemTests: XCTestCase {
    func testStringItem() {
        let string = "foo"

        let subject: XMLMixedContentItem = .string(string)

        XCTAssertEqual(subject.string, string)

        XCTAssertNil(subject.data)
        XCTAssertNil(subject.element)
    }

    func testDataItem() {
        let data = "foo".data(using: .utf8)!

        let subject: XMLMixedContentItem = .data(data)

        XCTAssertEqual(subject.data, data)

        XCTAssertNil(subject.string)
        XCTAssertNil(subject.element)
    }

    func testElementItem() {
        let element = XMLElementNode(
            name: "foo",
            attributes: [:],
            content: .empty(XMLEmptyContent())
        )

        let subject: XMLMixedContentItem = .element(element)

        XCTAssertEqual(subject.element, element)

        XCTAssertNil(subject.string)
        XCTAssertNil(subject.data)
    }

    static var allTests = [
        ("testStringItem", testStringItem),
        ("testStringItem", testStringItem),
        ("testDataItem", testDataItem),
        ("testElementItem", testElementItem),
    ]
}
