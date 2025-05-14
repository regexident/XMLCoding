import Foundation

import XMLDocument
import XMLFormatter

struct XMLUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    let key: CodingKey
    
    /// A reference to the encoder we're writing to.
    private let encoder: XMLInternalEncoder
    
    /// A reference to the container we're writing to.
    private let container: XMLElementNode
    
    /// The path of coding keys taken to get to this point in encoding.
    public let codingPath: [CodingKey]
    
    /// The number of elements encoded into the container.
    public var count: Int {
        let attributesCount = self.container.attributes.count
        let elementsCount: Int
        switch self.container.content {
        case .empty:
            elementsCount = 0
        case .simple:
            elementsCount = 1
        case .complex(let content):
            elementsCount = content.elements.count
        case .mixed(let content):
            elementsCount = content.items.count
        }
        return attributesCount + elementsCount
    }
    
    private var encodingKey: XMLEncodingKey {
        return XMLEncodingKey(
            key: self.key,
            at: self.codingPath,
            keyEncodingStrategy: self.encoder.options.keyEncodingStrategy
        )
    }
    
    // MARK: - Initialization
    
    /// Initializes `self` with the given references.
    init(
        key: CodingKey,
        referencing encoder: XMLInternalEncoder,
        codingPath: [CodingKey],
        wrapping container: XMLElementNode
    ) {
        self.key = key
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    // MARK: - Public:
    
    public mutating func encodeNil() throws {
        try self.encodeNil { encoder, key in
            try encoder.boxNilWithoutAffectingCodingPath(forKey: key)
        }
    }
    
    public mutating func encode(_ value: Bool) throws {
        try self.encode(value) { encoder, key, value in
            try encoder.boxWithoutAffectingCodingPath(bool: value, forKey: key)
        }
    }
    
    public mutating func encode<T: FixedWidthInteger & Encodable>(_ value: T) throws {
        try self.encode(value) { encoder, key, value in
            try encoder.boxWithoutAffectingCodingPath(integer: value, forKey: key)
        }
    }
    
    public mutating func encode<T: FixedWidthFloatingPoint & Encodable>(_ value: T) throws {
        try self.encode(value) { encoder, key, value in
            try encoder.boxWithoutAffectingCodingPath(floatingPoint: value, forKey: key)
        }
    }
    
    public mutating func encode(_ value: String) throws {
        try self.encode(value) { encoder, key, value in
            try value.encode(to: encoder)

            guard let container = encoder.popContainer() else {
                let name = encoder.resolve(encodingKey: key)
                return .empty(name: name)
            }

            return container
        }

//        try self.encode(value) { encoder, key, value in
//            try encoder.boxWithoutAffectingCodingPath(string: value, forKey: key)
//        }
    }
    
    public mutating func encode<T: Encodable>(_ value: T) throws {
        try self.encode(value) { encoder, key, value in
            try encoder.boxWithoutAffectingCodingPath(encodable: value, forKey: key)
        }
    }
    
    // MARK: - Internal:
    
    mutating func encode(_ value: Decimal) throws {
        try self.encode(value) { encoder, key, value in
            try encoder.boxWithoutAffectingCodingPath(decimal: value, forKey: key)
        }
    }
    
    mutating func encode(_ value: Date) throws {
        try self.encode(value) { encoder, key, value in
            try encoder.boxWithoutAffectingCodingPath(date: value, forKey: key)
        }
    }
    
    mutating func encode(_ value: Data) throws {
        try self.encode(value) { encoder, key, value in
            try encoder.boxWithoutAffectingCodingPath(data: value, forKey: key)
        }
    }
    
    mutating func encode(_ value: URL) throws {
        try self.encode(value) { encoder, key, value in
            try encoder.boxWithoutAffectingCodingPath(url: value, forKey: key)
        }
    }

    private mutating func encodeNil(
        encode: (XMLInternalEncoder, CodingKey) throws -> XMLElementNode
    ) rethrows {
        let element: XMLElementNode = try self.encoder.with(codingPath: self.codingPath) { encoder in
            encoder.codingPath.append(XMLInternalCodingKey(index: self.count))
            defer { encoder.codingPath.removeLast() }

            return try encode(encoder, self.key)
        }

        self.container.append(element: element)
    }

    private mutating func encode<T>(
        _ value: T,
        encode: (XMLInternalEncoder, CodingKey, T) throws -> XMLElementNode
    ) rethrows {
        let element: XMLElementNode = try self.encoder.with(codingPath: self.codingPath) { encoder in
            encoder.codingPath.append(XMLInternalCodingKey(index: self.count))
            defer { encoder.codingPath.removeLast() }
            
            return try encode(encoder, self.key, value)
        }
        
        self.container.append(element: element)
    }
    
    public mutating func nestedContainer<NestedKey>(
        keyedBy _: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> {
        print("📦: \(#function), key: \(NestedKey.self)")

        let codingKey = self.key
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
    
    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        print("📦: \(#function)")

        let codingKey = self.key
        var codingPath = self.codingPath
        codingPath.append(codingKey)
        
        return XMLUnkeyedEncodingContainer(
            key: codingKey,
            referencing: self.encoder,
            codingPath: codingPath,
            wrapping: self.container
        )
    }

    private mutating func nestedSingleValueContainer() -> SingleValueEncodingContainer {
        print("📦: \(#function)")

        return XMLSingleValueEncodingContainer(
            key: self.key,
            referencing: self.encoder,
            codingPath: self.codingPath,
            wrapping: self.container
        )
    }

    public mutating func superEncoder() -> Encoder {
        // print(#function, "key:", self.rootKey.stringValue, "codingPath:", self.codingPath.map { $0.stringValue }.joined(separator: "."))
        fatalError()
//        return XMLReferencingEncoder(
//            referencing: encoder,
//            at: self.count,
//            wrapping: container
//        )
    }
}
