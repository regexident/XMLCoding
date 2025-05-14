import XCTest

import SnapshotTesting

@testable import XMLCoding

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
class UnkeyedContainerTests: XCTestCase, EncodingTestCase {
    func testImplicitEncoding() {
        struct ImplicitEncoding: Codable {
            let unkeyed: [String] = [
                "value 0",
                "value 1",
            ]
        }

        let value = ImplicitEncoding()
        assertSnapshot(matching: value, as: .xml())
    }

    func testExplicitEncoding() {
        struct ExplicitEncoding: Codable {
            let unkeyed: [String] = [
                "value 0",
                "value 1",
            ]

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(self.unkeyed, forKey: .unkeyed)
            }
        }

        let value = ExplicitEncoding()
        assertSnapshot(matching: value, as: .xml())
    }

    func testManualEncoding() {
        struct ManualEncoding: Codable {
            let unkeyed: [String] = [
                "value 0",
                "value 1",
            ]

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .unkeyed)

                for value in self.unkeyed {
                    try unkeyedContainer.encode(value)
                }
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
