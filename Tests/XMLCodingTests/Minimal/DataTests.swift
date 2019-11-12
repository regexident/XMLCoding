import XCTest
@testable import XMLCoding

class DataTests: XCTestCase, EncodingTestCase {
    typealias Value = Data
    
    func testElement() throws {
        let value: Value = Data([0x64, 0x65, 0x61, 0x64, 0x62, 0x65, 0x65, 0x66])
        
        let action: EncodingTestAction = { encoder in
            try encoder.encode(value, rootKey: "container")
        }
        
        let compact = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = []
        }
        XCTAssertEqual(
            compact,
            """
            <container>ZGVhZGJlZWY=</container>
            """
        )
        
        let prettyPrinted = try self.withEncoder(action) { encoder in
            encoder.outputFormatting = [.prettyPrinted]
        }
        XCTAssertEqual(
            prettyPrinted,
            """
            <container>ZGVhZGJlZWY=</container>
            
            """
        )
    }
    
    static var allTests = [
        ("testElement", testElement),
    ]
}
