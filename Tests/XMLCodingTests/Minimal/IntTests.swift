import XCTest
@testable import XMLCoding

class IntTests: XCTestCase, EncodingTestCase {
    typealias Value = Int
    
    typealias TestAction = (XMLEncoder) throws -> Data
    
    func testElement() throws {
        let value: Value = -42
        
        let action: EncodingTestAction = { encoder in
            try encoder.encode(value, rootKey: "container")
        }
        
        let compact = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = []
        }
        XCTAssertEqual(
            compact,
            """
            <container>-42</container>
            """
        )
        
        let prettyPrinted = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = [.prettyPrinted]
        }
        XCTAssertEqual(
            prettyPrinted,
            """
            <container>-42</container>
            
            """
        )
    }
    
    static var allTests = [
        ("testElement", testElement),
    ]
}
