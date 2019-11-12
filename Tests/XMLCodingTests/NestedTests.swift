import XCTest
@testable import XMLCoding

class NestedTests: XCTestCase, EncodingTestCase {
    typealias Value = Container
    
    struct Container: Encodable {
        let single: Int = 42
        
        let keyed: [String: Int] = [
            "foo": 1,
            "bar": 2,
        ]
        
        let unkeyed: [String] = [
            "baz",
            "blee",
        ]
        
        enum CodingKeys: String, CodingKey {
            case single
            case keyed
            case unkeyed
        }
        
        enum KeyedCodingKeys: String, CodingKey {
            case foo
            case bar
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(self.single, forKey: .single)
            try container.encode(self.keyed, forKey: .keyed)
            try container.encode(self.unkeyed, forKey: .unkeyed)
        }
    }
    
    func testElement() throws {
        let value = Value()
        
        let action: EncodingTestAction = { encoder in
            try encoder.encode(value, rootKey: "container")
        }
        
        let compact = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = [.sortedKeys]
        }
        XCTAssertEqual(
            compact,
            """
            <container><keyed><bar>2</bar><foo>1</foo></keyed><single>42</single><unkeyed><unkeyed>baz</unkeyed><unkeyed>blee</unkeyed></unkeyed></container>
            """
        )
        
        let prettyPrinted = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        XCTAssertEqual(
            prettyPrinted,
            """
            <container>
                <keyed>
                    <bar>2</bar>
                    <foo>1</foo>
                </keyed>
                <single>42</single>
                <unkeyed>
                    <unkeyed>baz</unkeyed>
                    <unkeyed>blee</unkeyed>
                </unkeyed>
            </container>
            
            """
        )
    }
    
    static var allTests = [
        ("testElement", testElement),
    ]
}
