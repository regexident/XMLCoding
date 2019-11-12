import XCTest
@testable import XMLCoding

class EncodingCodingPathTests: XCTestCase {
    struct Baz: Equatable {
        let blee: Int
        
        enum CodingKeys: String, CodingKey {
            case blee
        }
    }
    
    struct Bar: Equatable {
        let baz: Baz
        
        enum CodingKeys: String, CodingKey {
            case baz
        }
    }
    
    struct Foo: Codable, Equatable {
        let bar: Bar
        
        init(bar: Bar) {
            self.bar = bar
        }
        
        enum CodingKeys: String, CodingKey {
            case bar
        }
        
        init(from decoder: Decoder) throws {
            let decoderCodingPath: [CodingKey] = []
            
            try XCTAssertEqualCodingPath(decoder.codingPath, decoderCodingPath)
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let containerCodingPath: [CodingKey] = []
            
            try XCTAssertEqualCodingPath(decoder.codingPath, decoderCodingPath)
            try XCTAssertEqualCodingPath(container.codingPath, containerCodingPath)
            
            let barCodingKey: Foo.CodingKeys = .bar
            let barContainer = try container.nestedContainer(keyedBy: Bar.CodingKeys.self, forKey: barCodingKey)
            let barContainerCodingPath: [CodingKey] = containerCodingPath + [barCodingKey]
            
            try XCTAssertEqualCodingPath(decoder.codingPath, decoderCodingPath)
            try XCTAssertEqualCodingPath(container.codingPath, containerCodingPath)
            try XCTAssertEqualCodingPath(barContainer.codingPath, barContainerCodingPath)
            
            let bazCodingKey: Bar.CodingKeys = .baz
            let bazContainer = try barContainer.nestedContainer(keyedBy: Baz.CodingKeys.self, forKey: bazCodingKey)
            let bazContainerCodingPath: [CodingKey] = barContainerCodingPath + [bazCodingKey]
            
            try XCTAssertEqualCodingPath(decoder.codingPath, decoderCodingPath)
            try XCTAssertEqualCodingPath(container.codingPath, containerCodingPath)
            try XCTAssertEqualCodingPath(barContainer.codingPath, barContainerCodingPath)
            try XCTAssertEqualCodingPath(bazContainer.codingPath, bazContainerCodingPath)
            
            let blee = try bazContainer.decode(Int.self, forKey: .blee)
            
            self.bar = Bar(
                baz: Baz(blee: blee)
            )
        }
        
        func encode(to encoder: Encoder) throws {
            let encoderCodingPath: [CodingKey] = []
            
            try XCTAssertEqualCodingPath(encoder.codingPath, encoderCodingPath)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            let containerCodingPath: [CodingKey] = []
            
            try XCTAssertEqualCodingPath(encoder.codingPath, encoderCodingPath)
//            try XCTAssertEqualCodingPath(container.codingPath, containerCodingPath)
            
            let bar = self.bar
            let barCodingKey: Foo.CodingKeys = .bar
            var barContainer = container.nestedContainer(keyedBy: Bar.CodingKeys.self, forKey: barCodingKey)
            let barContainerCodingPath: [CodingKey] = containerCodingPath + [barCodingKey]
            
            try XCTAssertEqualCodingPath(encoder.codingPath, encoderCodingPath)
//            try XCTAssertEqualCodingPath(container.codingPath, containerCodingPath)
//            try XCTAssertEqualCodingPath(barContainer.codingPath, barContainerCodingPath)
            
            let baz = bar.baz
            let bazCodingKey: Bar.CodingKeys = .baz
            var bazContainer = barContainer.nestedContainer(keyedBy: Baz.CodingKeys.self, forKey: bazCodingKey)
            let bazContainerCodingPath: [CodingKey] = barContainerCodingPath + [bazCodingKey]
            
            try XCTAssertEqualCodingPath(encoder.codingPath, encoderCodingPath)
//            try XCTAssertEqualCodingPath(container.codingPath, containerCodingPath)
//            try XCTAssertEqualCodingPath(barContainer.codingPath, barContainerCodingPath)
//            try XCTAssertEqualCodingPath(bazContainer.codingPath, bazContainerCodingPath)
            
            let blee = baz.blee
            try bazContainer.encode(blee, forKey: .blee)
        }
    }
    
    func test_encode_xml() throws {
        let encoder = XMLEncoder()
        
        let value = Foo(bar: Bar(baz: Baz(blee: 42)))
        
        XCTAssertNoThrow(try encoder.encode(value, rootKey: "foo"))
//        do {
//            let _ = try encoder.encode(value, rootKey: "foo")
//        } catch let error {
//            XCTFail(type(of: error), error.localizedDescription)
//        }
    }
    
    func test_encode_json() throws {
        let encoder = JSONEncoder()
        
        let value = Foo(bar: Bar(baz: Baz(blee: 42)))
        
        XCTAssertNoThrow(try encoder.encode(value))
//        do {
//            let _ = try encoder.encode(value)
//        } catch let error {
//            XCTFail(error.localizedDescription)
//        }
    }
    
//    func test_decode_json() throws {
//        let decoder = JSONDecoder()
//
//        let data =
//        """
//        { "bar": { "baz": { "blee": 42 } } }
//        """.data(using: .utf8)!
//
//        XCTAssertNoThrow(try decoder.decode(Foo.self, from: data))
    ////        do {
    ////            let _ = try decoder.decode(Foo.self, from: data)
    ////        } catch let error {
    ////            XCTFail(type(of: error), error.localizedDescription)
    ////        }
//    }
}
