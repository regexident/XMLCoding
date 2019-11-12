import XCTest
@testable import XMLCoding

class StringTests: XCTestCase, EncodingTestCase {
    typealias Value = String
    
    func testElement() throws {
        let value: Value = "lorem ipsum"
        
        let action: EncodingTestAction = { encoder in
            try encoder.encode(value, rootKey: "container")
        }
        
        let compact = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = []
        }
        XCTAssertEqual(
            compact,
            """
            <container>lorem ipsum</container>
            """
        )
        
        let prettyPrinted = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = [.prettyPrinted]
        }
        XCTAssertEqual(
            prettyPrinted,
            """
            <container>lorem ipsum</container>
            
            """
        )
    }
    
    static var allTests = [
        ("testElement", testElement),
    ]
}
