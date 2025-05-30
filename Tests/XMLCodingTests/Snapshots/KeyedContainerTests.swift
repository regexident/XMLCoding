import XCTest

import SnapshotTesting

@testable import XMLCoding

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
class KeyedContainerTests: XCTestCase, EncodingTestCase {
    func testImplicitEncoding() {
        struct ImplicitEncoding: Codable {
            let keyed: [String: String] = [
                "foo": "foo value",
                "bar": "bar value",
            ]
        }
        
        let value = ImplicitEncoding()
        assertSnapshot(matching: value, as: .xml())
    }
    
    func testExplicitEncoding() {
        struct ExplicitEncoding: Codable {
            let keyed: [String: String] = [
                "foo": "foo value",
                "bar": "bar value",
            ]
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                
                try container.encode(self.keyed, forKey: .keyed)
            }
        }
        
        let value = ExplicitEncoding()
        assertSnapshot(matching: value, as: .xml())
    }
    
    func testManualEncoding() {
        struct ManualEncoding: Codable {
            enum KeyedCodingKeys: String, CodingKey {
                case foo
                case bar
            }

            let keyed: [String: String] = [
                "foo": "foo value",
                "bar": "bar value",
            ]
            
            func encode(to encoder: Encoder) throws {
//                try self.keyed.encode(to: encoder)
                var container = encoder.container(keyedBy: CodingKeys.self)
//
                var keyedContainer = container.nestedContainer(keyedBy: KeyedCodingKeys.self, forKey: .keyed)
                try keyedContainer.encode(self.keyed["foo"]!, forKey: .foo)
                try keyedContainer.encode(self.keyed["bar"]!, forKey: .bar)
            }
        }
        
        let value = ManualEncoding()
        assertSnapshot(matching: value, as: .xml())
    }
    
    static var allTests = [
        ("testImplicitEncoding", testImplicitEncoding),
        ("testExplicitEncoding", testExplicitEncoding),
        ("testManualEncoding", testManualEncoding),
    ]
}
