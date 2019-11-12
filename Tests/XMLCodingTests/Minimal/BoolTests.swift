import XCTest
@testable import XMLCoding

class BoolTests: XCTestCase, EncodingTestCase {
    typealias Value = Bool
    
    func testElement() throws {
        let value: Value = true
        
        let action: EncodingTestAction = { encoder in
            try encoder.encode(value, rootKey: "container")
        }
        
        let compact = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = []
        }
        
        XCTAssertEqual(
            compact,
            """
            <container>true</container>
            """
        )
        
        let prettyPrinted = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = [.prettyPrinted]
        }
        
        XCTAssertEqual(
            prettyPrinted,
            """
            <container>true</container>
            
            """
        )
    }
    
    static var allTests = [
        ("testElement", testElement),
    ]
}
