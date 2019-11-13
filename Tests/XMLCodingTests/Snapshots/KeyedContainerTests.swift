import XCTest

import SnapshotTesting

@testable import XMLCoding

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
class KeyedContainerTests: XCTestCase, EncodingTestCase {
    enum Keyed {
        enum CodingKeys: String, CodingKey {
            case foo
            case bar
        }
        
        typealias Value = [String: String]
        
        static let value: Value = [
            "foo": "foo value",
            "bar": "bar value",
        ]
    }
    
    func testImplicitEncoding() {
        struct ImplicitEncoding: Codable {
            enum CodingKeys: String, CodingKey {
                case keyed
            }
            
            let keyed: Keyed.Value = Keyed.value
        }
        
        let value = ImplicitEncoding()
        assertSnapshot(matching: value, as: .xml())
    }
    
    func testExplicitEncoding() {
        struct ExplicitEncoding: Codable {
            enum CodingKeys: String, CodingKey {
                case keyed
            }
            
            let keyed: Keyed.Value = Keyed.value
            
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
            enum CodingKeys: String, CodingKey {
                case keyed
            }
            
            let keyed: Keyed.Value = Keyed.value
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                
                var keyedContainer = container.nestedContainer(keyedBy: Keyed.CodingKeys.self, forKey: .keyed)
                try keyedContainer.encode(self.keyed["foo"], forKey: .foo)
                try keyedContainer.encode(self.keyed["bar"], forKey: .bar)
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
