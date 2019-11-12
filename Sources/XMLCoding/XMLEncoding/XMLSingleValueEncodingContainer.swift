import Foundation

import XMLDocument
import XMLFormatter

internal struct XMLSingleValueEncodingContainer: SingleValueEncodingContainer {
    internal let key: CodingKey
    internal let codingPath: [CodingKey]
    
    private let encoder: XMLInternalEncoder
    
//    private var encodingKey: XMLEncodingKey {
//        return XMLEncodingKey(
//            key: self.key,
//            at: self.codingPath,
//            keyEncodingStrategy: self.encoder.options.keyEncodingStrategy
//        )
//    }
    
    internal init(
        key: CodingKey,
        referencing encoder: XMLInternalEncoder,
        codingPath: [CodingKey]
    ) {
        self.key = key
        self.encoder = encoder
        self.codingPath = codingPath
    }
    
    // MARK: - Public:
    
    public func encodeNil() throws {
        self.assertCanEncodeNewValue()
        
        try self.encoder.with(codingPath: self.codingPath) { encoder in
            let boxed = try encoder.box(null: (), forKey: self.key)
            
            self.encoder.push(container: boxed)
        }
    }
    
    public func encode(_ value: Bool) throws {
        self.assertCanEncodeNewValue()
        
        try self.encode(value) { encoder, value in
            try encoder.box(bool: value, forKey: self.key)
        }
    }
    
    public func encode<T: FixedWidthInteger & Encodable>(_ value: T) throws {
        self.assertCanEncodeNewValue()
        
        try self.encode(value) { encoder, value in
            try encoder.box(integer: value, forKey: self.key)
        }
    }
    
    public func encode<T: FixedWidthFloatingPoint & Encodable>(_ value: T) throws {
        self.assertCanEncodeNewValue()
        
        try self.encode(value) { encoder, value in
            try encoder.box(floatingPoint: value, forKey: self.key)
        }
    }
    
    public func encode(_ value: String) throws {
        self.assertCanEncodeNewValue()
        
        try self.encode(value) { encoder, value in
            try encoder.box(string: value, forKey: self.key)
        }
    }
    
    public func encode<T: Encodable>(_ value: T) throws {
        self.assertCanEncodeNewValue()
        
        try self.encode(value) { encoder, value in
            try encoder.box(encodable: value, forKey: self.key)
        }
    }
    
    internal func encodeWithoutAffectingCodingPath<T: Encodable>(_ value: T) throws {
        self.assertCanEncodeNewValue()
        
        try self.encode(value) { encoder, value in
            try encoder.boxWithoutAffectingCodingPath(encodable: value, forKey: self.key)
        }
    }
    
    private func encode<T: Encodable>(
        _ value: T,
        encode: (XMLInternalEncoder, T) throws -> XMLElementNode
    ) rethrows {
        try self.encoder.with(codingPath: self.codingPath) { encoder in
            let boxed = try encode(encoder, value)
            
            self.encoder.push(container: boxed)
        }
    }
    
    fileprivate func assertCanEncodeNewValue() {
        precondition(
            self.encoder.canEncodeNewValue,
            "Attempt to encode value through single value container when previously value already encoded."
        )
    }
}
