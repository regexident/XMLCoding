import XCTest
@testable import XMLCoding

class URLTests: XCTestCase, EncodingTestCase {
    typealias Value = URL
    
    func testElement() throws {
        let value: Value = URL(string: "http://example.com")!
        
        let action: EncodingTestAction = { encoder in
            try encoder.encode(value, rootKey: "container")
        }
        
        let compact = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = []
        }
        XCTAssertEqual(
            compact,
            """
            <container>http://example.com</container>
            """
        )
        
        let prettyPrinted = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = [.prettyPrinted]
        }
        XCTAssertEqual(
            prettyPrinted,
            """
            <container>http://example.com</container>
            
            """
        )
    }
    
    static var allTests = [
        ("testElement", testElement),
    ]
}
