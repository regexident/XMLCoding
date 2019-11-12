import XCTest
@testable import XMLCoding

protocol EncodingTestCase {
    typealias Value = URL
    
    typealias EncodingTestAction = (XMLEncoder) throws -> Data
    typealias EncodingTestConfiguration = (XMLEncoder) throws -> ()
    
    func withEncoder(
        _ action: EncodingTestAction,
        _ configuration: EncodingTestConfiguration
    ) rethrows -> String
}

extension EncodingTestCase {
    func withEncoder(
        _ action: EncodingTestAction,
        _ configuration: EncodingTestConfiguration
    ) rethrows -> String {
        let encoder = XMLEncoder()
        
        try configuration(encoder)
        
        let encoded = try action(encoder)
        
        let encodedString = String(data: encoded, encoding: .utf8)!
        
        return encodedString
    }
}
