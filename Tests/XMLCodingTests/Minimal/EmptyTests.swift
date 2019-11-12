import XCTest
@testable import XMLCoding

class EmptyTests: XCTestCase, EncodingTestCase {
    struct Value: Encodable {
        func encode(to encoder: Encoder) throws {
            // intentionally left blank.
        }
    }
    
    func testElement() throws {
        let value: Value = .init()
        
        let action: EncodingTestAction = { encoder in
            try encoder.encode(value, rootKey: "container")
        }
        
        let compact = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = []
        }
        XCTAssertEqual(
            compact,
            """
            <container/>
            """
        )
        
        let prettyPrinted = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = [.prettyPrinted]
        }
        XCTAssertEqual(
            prettyPrinted,
            """
            <container/>
            
            """
        )
    }
    
    static var allTests = [
        ("testElement", testElement),
    ]
}
