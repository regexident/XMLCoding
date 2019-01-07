import XCTest
@testable import XMLDocument

class XMLElementNodeTests: XCTestCase {
    let elementName: String = "foo"
    let attributes: [String: String] = ["bar": "baz"]
    let content: XMLElementNodeContent = .empty(XMLEmptyContent())
    
    func element() -> XMLElementNode {
        return XMLElementNode(
            info: XMLElementNodeInfo(name: self.elementName),
            attributes: self.attributes,
            content: self.content
        )
    }
}

// MARK: - Initialize elements
extension XMLElementNodeTests {
    func test_init() {
        let subject = self.element()
        
        XCTAssertEqual(subject.info.name, self.elementName)
        XCTAssertEqual(subject.attributes, self.attributes)
        XCTAssertEqual(subject.content, self.content)
    }
    
    func test_empty() {
        let subject = XMLElementNode.empty(name: self.elementName)
        
        XCTAssertNotNil(subject.content.isEmpty)
    }
    
    func test_string() {
        let subject = XMLElementNode.string(name: self.elementName, string: "foo")
        
        XCTAssertTrue(subject.content.isSimple)
    }
    
    func test_data() {
        let subject = XMLElementNode.data(name: self.elementName, data: "foo".data(using: .utf8)!)
        
        XCTAssertTrue(subject.content.isSimple)
    }
    
    func test_complex() {
        let subject = XMLElementNode.complex(name: self.elementName, elements: [])
        
        XCTAssertTrue(subject.content.isComplex)
    }
    
    func test_mixed() {
        let subject = XMLElementNode.mixed(name: self.elementName, items: [])
        
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
            info: XMLElementNodeInfo(name: self.elementName),
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
