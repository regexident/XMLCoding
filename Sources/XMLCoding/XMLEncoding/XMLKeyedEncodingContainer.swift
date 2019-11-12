import Foundation

import XMLDocument
import XMLFormatter

// FIXME: Remove!
extension Array where Element == CodingKey {
    var asString: String {
        return self.map { $0.stringValue }.joined(separator: ".")
    }
}

struct XMLKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K
    
    private let encoder: XMLInternalEncoder
    
    private let element: XMLElementNode
    
    public let codingPath: [CodingKey]
    
    init(
        referencing encoder: XMLInternalEncoder,
        codingPath: [CodingKey],
        wrapping element: XMLElementNode
    ) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.element = element
    }
    
    public mutating func encodeNil(forKey key: Key) throws {
        let name = self.encoder.resolve(encodingKey: key)
        let element = XMLElementNode.empty(name: name)
        self.element.append(element: element)
    }
    
    public mutating func encode(_ value: Bool, forKey key: Key) throws {
        return try self.encode(value, forKey: key) { encoder, key, value in
            try encoder.box(bool: value, forKey: key)
        }
    }
    
    public mutating func encode(_ value: Decimal, forKey key: Key) throws {
        return try self.encode(value, forKey: key) { encoder, key, value in
            try encoder.box(decimal: value, forKey: key)
        }
    }
    
    public mutating func encode<T: FixedWidthInteger & Encodable>(_ value: T, forKey key: Key) throws {
        return try self.encode(value, forKey: key) { encoder, key, value in
            try encoder.box(integer: value, forKey: key)
        }
    }
    
    public mutating func encode<T: FixedWidthFloatingPoint & Encodable>(_ value: T, forKey key: Key) throws {
        return try self.encode(value, forKey: key) { encoder, key, value in
            try encoder.box(floatingPoint: value, forKey: key)
        }
    }
    
    public mutating func encode(_ value: String, forKey key: Key) throws {
        return try self.encode(value, forKey: key) { encoder, key, value in
            try encoder.box(string: value, forKey: key)
        }
    }
    
    public mutating func encode(_ value: Date, forKey key: Key) throws {
        return try self.encode(value, forKey: key) { encoder, key, value in
            try encoder.box(date: value, forKey: key)
        }
    }
    
    public mutating func encode(_ value: Data, forKey key: Key) throws {
        return try self.encode(value, forKey: key) { encoder, key, value in
            try encoder.box(data: value, forKey: key)
        }
    }
    
    public mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        return try self.encode(value, forKey: key) { encoder, _, value in
            try encoder.box(encodable: value, forKey: key)
        }
    }
    
    private mutating func encode<T: Encodable>(
        _ value: T,
        forKey key: Key,
        encode: (XMLInternalEncoder, CodingKey, T) throws -> XMLElementNode
    ) throws {
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        let options = self.encoder.options
        let nodeEncodings = options.nodeEncodingStrategy.nodeEncodings(
            forType: T.self,
            with: self.encoder
        )
        self.encoder.nodeEncodings.append(nodeEncodings)
        defer {
            _ = self.encoder.nodeEncodings.removeLast()
        }
        
        let element = try self.encoder.with(codingPath: self.codingPath) { encoder in
            try encode(encoder, key, value)
        }
        
        switch strategy(key) {
        case .attribute:
            guard case .simple(.string(let string)) = element.content else {
                throw EncodingError.invalidValue(value, EncodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Unable to encode the given complex value to an attribute."
                ))
            }
            let name = self.encoder.resolve(encodingKey: key)
            self.element.attributes[name] = string
        case .element:
            self.element.append(element: element)
        }
    }
    
    public mutating func nestedContainer<NestedKey>(
        keyedBy _: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> {
        var codingPath = self.codingPath
        codingPath.append(key)
        
        let keyEncodingStrategy = self.encoder.options.keyEncodingStrategy
        
        let encodingKey = XMLEncodingKey(
            key: key,
            at: codingPath,
            keyEncodingStrategy: keyEncodingStrategy
        )
        
        let element = XMLElementNode.empty(name: encodingKey.xmlKey)
        
        let container = XMLKeyedEncodingContainer<NestedKey>(
            referencing: self.encoder,
            codingPath: codingPath,
            wrapping: element
        )
        
        return KeyedEncodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer(
        forKey key: Key
    ) -> UnkeyedEncodingContainer {
        var codingPath = self.codingPath
        codingPath.append(key)
        
        let keyEncodingStrategy = self.encoder.options.keyEncodingStrategy
        
        let encodingKey = XMLEncodingKey(
            key: key,
            at: codingPath,
            keyEncodingStrategy: keyEncodingStrategy
        )
        
        let element = XMLElementNode.empty(name: encodingKey.xmlKey)
        
        return XMLUnkeyedEncodingContainer(
            key: key,
            referencing: self.encoder,
            codingPath: codingPath,
            wrapping: element
        )
    }
    
    public mutating func superEncoder() -> Encoder {
        // print(#function, "key:", self.rootKey.stringValue, "codingPath:", self.codingPath.map { $0.stringValue }.joined(separator: "."))
        fatalError()
//        return _XMLReferencingEncoder(
//            referencing: encoder,
//            key: XMLCodingKey.super,
//            convertedKey: _converted(XMLCodingKey.super),
//            wrapping: container
//        )
    }
    
    public mutating func superEncoder(forKey key: Key) -> Encoder {
        // print(#function, "key:", self.rootKey.stringValue, "codingPath:", self.codingPath.map { $0.stringValue }.joined(separator: "."))
        fatalError()
//        return _XMLReferencingEncoder(
//            referencing: encoder,
//            key: key,
//            convertedKey: _converted(key),
//            wrapping: container
//        )
    }
}
