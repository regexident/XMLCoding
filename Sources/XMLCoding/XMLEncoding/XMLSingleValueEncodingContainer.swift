import Foundation

import XMLDocument
import XMLFormatter

struct XMLSingleValueEncodingContainer: SingleValueEncodingContainer {
    private let encoder: XMLInternalEncoder

    private let container: XMLElementNode?

    private let key: CodingKey
    let codingPath: [CodingKey]

    init(
        key: CodingKey,
        referencing encoder: XMLInternalEncoder,
        codingPath: [CodingKey],
        wrapping container: XMLElementNode?
    ) {
        self.key = key
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    // MARK: - Public:
    
    public func encodeNil() throws {
        self.assertCanEncodeNewValue()

        try self.encodeNil { encoder in
            try encoder.boxNilWithoutAffectingCodingPath(forKey: self.key)
        }
    }
    
    public func encode(_ value: Bool) throws {
        self.assertCanEncodeNewValue()
        
        try self.encode(value) { encoder, value in
            try encoder.boxWithoutAffectingCodingPath(bool: value, forKey: self.key)
        }
    }
    
    public func encode<T: FixedWidthInteger & Encodable>(_ value: T) throws {
        self.assertCanEncodeNewValue()
        
        try self.encode(value) { encoder, value in
            try encoder.boxWithoutAffectingCodingPath(integer: value, forKey: self.key)
        }
    }
    
    public func encode<T: FixedWidthFloatingPoint & Encodable>(_ value: T) throws {
        self.assertCanEncodeNewValue()
        
        try self.encode(value) { encoder, value in
            try encoder.boxWithoutAffectingCodingPath(floatingPoint: value, forKey: self.key)
        }
    }
    
    public func encode(_ value: String) throws {
        self.assertCanEncodeNewValue()
        
        try self.encode(value) { encoder, value in
            try encoder.boxWithoutAffectingCodingPath(string: value, forKey: self.key)
        }
    }

    public func encode<T: Encodable>(_ value: T) throws {
        self.assertCanEncodeNewValue()
        
        try self.encode(value) { encoder, value in
            try encoder.boxWithoutAffectingCodingPath(encodable: value, forKey: self.key)
        }
    }
    
    func encodeWithoutAffectingCodingPath<T: Encodable>(_ value: T) throws {
        self.assertCanEncodeNewValue()

        try self.encode(value) { encoder, value in
            try encoder.boxWithoutAffectingCodingPath(encodable: value, forKey: self.key)
        }
    }

    private func encodeNil(
        encode: (XMLInternalEncoder) throws -> XMLElementNode
    ) rethrows {
        try self.encoder.with(codingPath: self.codingPath) { encoder in
            let boxed = try encode(encoder)

            self.encoder.push(container: boxed)
        }
    }

    private func encode<T: Encodable>(
        _ value: T,
        encode: (XMLInternalEncoder, T) throws -> XMLElementNode
    ) throws {
        let key = self.key

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
            try encode(encoder, value)
        }

        switch strategy(key) {
        case .attribute:
            guard let container = self.container else {
                fatalError("Attribute encoding is unavailable for root element.")
            }
            guard case .simple(.string(let string)) = element.content else {
                throw EncodingError.invalidValue(value, EncodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Unable to encode the given complex value to an attribute."
                ))
            }
            let name = self.encoder.resolve(encodingKey: key)
            container.attributes[name] = string
        case .element:
            self.encoder.push(container: element)
        }

//        try self.encoder.with(codingPath: self.codingPath) { encoder in
//            let boxed = try encode(encoder, value)
//
//            self.encoder.push(container: boxed)
//        }
    }
    
    fileprivate func assertCanEncodeNewValue() {
        precondition(
            self.encoder.canEncodeNewValue,
            "Attempt to encode value through single value container when previously value already encoded."
        )
    }
}
