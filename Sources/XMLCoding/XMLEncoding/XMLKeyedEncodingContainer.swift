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
    
    private let container: XMLElementNode
    
    public let codingPath: [CodingKey]
    
    init(
        referencing encoder: XMLInternalEncoder,
        codingPath: [CodingKey],
        wrapping container: XMLElementNode
    ) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    public mutating func encodeNil(forKey key: Key) throws {
        return try self.encodeNil(forKey: key) { encoder, key in
            try encoder.boxNil(forKey: key)
        }
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

    private mutating func encodeNil(
        forKey key: Key,
        encode: (XMLInternalEncoder, CodingKey) throws -> XMLElementNode
    ) throws {
        let element = try self.encoder.with(codingPath: self.codingPath) { encoder in
            try encode(encoder, key)
        }

        self.container.append(element: element)
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
            self.container.attributes[name] = string
        case .element:
            self.container.append(element: element)
        }
    }
    
    public mutating func nestedContainer<NestedKey>(
        keyedBy _: NestedKey.Type,
        forKey codingKey: Key
    ) -> KeyedEncodingContainer<NestedKey> {
        print("📦: \(#function), key: \(Key.self)")

        var codingPath = self.codingPath
        codingPath.append(codingKey)
        
        let keyEncodingStrategy = self.encoder.options.keyEncodingStrategy
        let encodingKey = XMLEncodingKey(
            key: codingKey,
            at: codingPath,
            keyEncodingStrategy: keyEncodingStrategy
        )
        
        let container = XMLElementNode.empty(name: encodingKey.xmlKey)
        self.container.append(element: container)
        
        return KeyedEncodingContainer(XMLKeyedEncodingContainer<NestedKey>(
            referencing: self.encoder,
            codingPath: codingPath,
            wrapping: container
        ))
    }
    
    public mutating func nestedUnkeyedContainer(
        forKey codingKey: Key
    ) -> UnkeyedEncodingContainer {
        print("📦: \(#function)")
        
        var codingPath = self.codingPath
        codingPath.append(codingKey)
        
        return XMLUnkeyedEncodingContainer(
            key: codingKey,
            referencing: self.encoder,
            codingPath: codingPath,
            wrapping: self.container
        )
    }
    
    public mutating func superEncoder() -> Encoder {
        // print(#function, "key:", self.rootKey.stringValue, "codingPath:", self.codingPath.map { $0.stringValue }.joined(separator: "."))
        fatalError()
//        return _XMLReferencingEncoder(
//            referencing: encoder,
//            key: XMLInternalCodingKey.super,
//            convertedKey: _converted(XMLInternalCodingKey.super),
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
