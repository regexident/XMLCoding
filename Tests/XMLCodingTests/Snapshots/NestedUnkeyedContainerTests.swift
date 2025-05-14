// import XCTest
//
// import SnapshotTesting
//
// @testable import XMLCoding
//
// @available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
// class NestedUnkeyedContainerTests: XCTestCase, EncodingTestCase {
//    func testImplicitEncoding() {
//        struct ImplicitEncoding: Encodable {
//            enum CodingKeys: String, CodingKey {
//                case unkeyed
//            }
//
//            enum XMLInternalCodingKeys: String, CodingKey {
//                case foo
//            }
//
//            @XMLInternalCodingKeyPath(codingKeys: [XMLInternalCodingKeys.foo])
//            var unkeyed: [[String]] = [
//                ["value 0"],
//                ["value 1"],
//            ]
//        }
//
////        let value = ImplicitEncoding()
////        assertSnapshot(matching: value, as: .xml())
//
//        let value = ImplicitEncoding()
//        let encoder = XMLEncoder()
//        encoder.outputFormatting = [.prettyPrinted]
//        let data = try! encoder.encode(value, rootKey: "root")
//        let string = String(data: data, encoding: .utf8)!
//        print(string)
//        fatalError()
//    }
//
////    func testExplicitEncoding() {
////        struct ExplicitEncoding: Codable {
////            enum CodingKeys: String, CodingKey {
////                case unkeyed
////            }
////
////            let unkeyed: Unkeyed.Value = Unkeyed.value
////
////            func encode(to encoder: Encoder) throws {
////                var container = encoder.container(keyedBy: CodingKeys.self)
////
////                try container.encode(self.unkeyed, forKey: .unkeyed)
////            }
////        }
////
////        let value = ExplicitEncoding()
////        assertSnapshot(matching: value, as: .xml())
////    }
////
////    func testManualEncoding() {
////        struct ManualEncoding: Codable {
////            enum CodingKeys: String, CodingKey {
////                case unkeyed
////            }
////
////            let unkeyed: Unkeyed.Value = Unkeyed.value
////
////            func encode(to encoder: Encoder) throws {
////                var container = encoder.container(keyedBy: CodingKeys.self)
////
////                var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .unkeyed)
////
////                for value in self.unkeyed {
////                    try unkeyedContainer.encode(value)
////                }
////            }
////        }
////
////        let value = ManualEncoding()
////        assertSnapshot(matching: value, as: .xml())
////    }
//
//    static var allTests = [
//        ("testImplicitEncoding", testImplicitEncoding),
////        ("testExplicitEncoding", testExplicitEncoding),
////        ("testManualEncoding", testManualEncoding),
//    ]
// }
