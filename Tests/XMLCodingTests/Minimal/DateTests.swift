import XCTest
@testable import XMLCoding

class DateTests: XCTestCase, EncodingTestCase {
    typealias Value = Date
    
    func testElement() throws {
        let value: Value = Date(timeIntervalSince1970: 0.0)
        
        let action: EncodingTestAction = { encoder in
            try encoder.encode(value, rootKey: "container")
        }
        
        let compact = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = []
        }
        XCTAssertEqual(
            compact,
            """
            <container>-978307200.0</container>
            """
        )
        
        let prettyPrinted = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = [.prettyPrinted]
        }
        XCTAssertEqual(
            prettyPrinted,
            """
            <container>-978307200.0</container>
            
            """
        )
    }
    
    static var allTests = [
        ("testElement", testElement),
    ]
}
