import Foundation

import XMLDocument
import XMLFormatter

class XMLInternalEncoder: Encoder {
    typealias Container = XMLEncodingStorage.Container
    
    /// The encoded document's root key.
    private let rootKey: CodingKey
    
    /// The encoder's storage.
    private var storage: XMLEncodingStorage
    
    /// Options set on the top-level encoder.
    let options: XMLEncoder._Options
    
    /// The path to the current point in encoding.
    public var codingPath: [CodingKey] {
        didSet {
            let old = oldValue.map { "\(StringConvertibleCodingKey($0))" }.joined(separator: ".")
            let new = self.codingPath.map { "\(StringConvertibleCodingKey($0))" }.joined(separator: ".")
            print("⚠️", "\"\(old)\"", "->", "\"\(new)\"")
        }
    }

    var currentCodingKey: CodingKey {
        return self.codingPath.last ?? self.rootKey
    }
    
    public var nodeEncodings: [(CodingKey) -> XMLEncoder.NodeEncoding]
    
    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] {
        return self.options.userInfo
    }
    
    var containerStackCount: Int {
        return self.storage.count
    }
    
    /// Initializes `self` with the given top-level encoder options.
    init(
        rootKey: CodingKey,
        options: XMLEncoder._Options,
        nodeEncodings: [(CodingKey) -> XMLEncoder.NodeEncoding],
        codingPath: [CodingKey]
    ) {
        self.rootKey = rootKey
        self.storage = XMLEncodingStorage()
        self.options = options
        self.codingPath = codingPath
        self.nodeEncodings = nodeEncodings
    }

    private func withCodingPath<T>(
        appending codingKey: CodingKey,
        _ closure: () throws -> T
    ) rethrows -> T {
        self.codingPath.append(codingKey)
        defer {
            // Reset to previous value when done:
            self.codingPath.removeLast()
        }

        return try closure()
    }
    
    func with<T>(codingPath: [CodingKey], _ closure: (XMLInternalEncoder) throws -> T) rethrows -> T {
        let previousCodingPath = self.codingPath
        defer {
            // Reset to previous value when done:
            self.codingPath = previousCodingPath
        }
        self.codingPath = codingPath
        return try closure(self)
    }
    
    func resolve(encodingKey codingKey: CodingKey) -> String {
        let encodingKey = XMLEncodingKey(
            key: codingKey,
            at: self.codingPath,
            keyEncodingStrategy: self.options.keyEncodingStrategy
        )
        
        return encodingKey.xmlKey
    }
    
    func push(container: Container) {
        self.storage.push(container: container)
    }
    
    func popContainer() -> Container? {
        return self.storage.popContainer()
    }
    
    /// Returns whether a new element can be encoded at this coding path.
    ///
    /// `true` if an element has not yet been encoded at this coding path; `false` otherwise.
    var canEncodeNewValue: Bool {
        // Encodable:
        
        // Every time a new value gets encoded, the key it's encoded for is pushed onto the coding path (even if it's a nil key from an unkeyed container).
        // At the same time, every time a container is requested, a new value gets pushed onto the storage stack.
        // If there are more values on the storage stack than on the coding path, it means the value is requesting more than one container, which violates the precondition.
        //
        // This means that anytime something that can request a new container goes onto the stack, we MUST push a key onto the coding path.
        // Things which will not request containers do not need to have the coding path extended for them (but it doesn't matter if it is, because they will not reach here).
        
        // XMLEncodable:
        
        // Every XML node has a name. Even the root node, which is not part of the coding path:
        // As such we subtract `1` from `self.storage.count`, when comparing:
        
//        return (self.storage.count - 1) <= self.codingPath.count

        return true
    }
    
    public func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> {
        print("📦: \(#function), key: \(Key.self)")

        let codingKey = self.currentCodingKey
        let name = self.resolve(encodingKey: codingKey)
        let container = XMLElementNode.empty(name: name)
        self.storage.push(container: container)
        
        return KeyedEncodingContainer(XMLKeyedEncodingContainer<Key>(
            referencing: self,
            codingPath: self.codingPath,
            wrapping: container
        ))
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        print("📦: \(#function)")

        let codingKey = self.currentCodingKey

        guard let container = self.storage.lastContainer else {
            preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
        }

        return XMLUnkeyedEncodingContainer(
            key: codingKey,
            referencing: self,
            codingPath: self.codingPath,
            wrapping: container
        )
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        print("📦: \(#function)")

        guard let container = self.storage.lastContainer else {
            preconditionFailure("Attempt to push new single value encoding container when already previously encoded at this path.")
        }

        return XMLSingleValueEncodingContainer(
            key: self.currentCodingKey,
            referencing: self,
            codingPath: self.codingPath,
            wrapping: container
        )

//        let codingKey = self.currentCodingKey
//        let name = self.resolve(encodingKey: codingKey)
//        let container = XMLElementNode.empty(name: name)
//        self.storage.push(container: container)
//
//        return XMLSingleValueEncodingContainer(
//            key: self.currentCodingKey,
//            referencing: self,
//            codingPath: self.codingPath
//        )
    }
}

// MARK: - Boxing:

extension XMLInternalEncoder {
    // MARK: - Public:

    func boxNil(forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: <()>, key: \"\(StringConvertibleCodingKey(key))\"")

        return try self.withCodingPath(appending: key) {
            try self.boxNilWithoutAffectingCodingPath(forKey: key)
        }
    }

    func boxNilWithoutAffectingCodingPath(forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: <()>, key: \"\(StringConvertibleCodingKey(key))\"")

        let name = self.resolve(encodingKey: key)
        
        return .empty(name: name)
    }

    func box(bool value: Bool, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        return try self.withCodingPath(appending: key) {
            try self.boxWithoutAffectingCodingPath(bool: value, forKey: key)
        }
    }

    func boxWithoutAffectingCodingPath(bool value: Bool, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        let name = self.resolve(encodingKey: key)
        
        let formatter = XMLBoolFormatter()
        let string = try formatter.string(from: value)
        
        return .string(name: name, string: string)
    }

    func box<T: FixedWidthInteger>(integer value: T, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        return try self.withCodingPath(appending: key) {
            try self.boxWithoutAffectingCodingPath(integer: value, forKey: key)
        }
    }

    func boxWithoutAffectingCodingPath<T: FixedWidthInteger>(integer value: T, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        let name = self.resolve(encodingKey: key)
        
        let formatter = XMLIntegerFormatter<T>()
        let string = try formatter.string(from: value)
        
        return .string(name: name, string: string)
    }

    func box<T: FixedWidthFloatingPoint>(floatingPoint value: T, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        return try self.withCodingPath(appending: key) {
            try self.boxWithoutAffectingCodingPath(floatingPoint: value, forKey: key)
        }
    }

    func boxWithoutAffectingCodingPath<T: FixedWidthFloatingPoint>(floatingPoint value: T, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        let name = self.resolve(encodingKey: key)
        
        func nonConformingStrings() throws -> (String, String, String) {
            let strategy = self.options.nonConformingFloatEncodingStrategy
            guard case .convertToString(positiveInfinity: let posInf, negativeInfinity: let negInf, nan: let nan) = strategy else {
                throw EncodingError._invalidFloatingPointValue(value, at: self.codingPath)
            }
            return (posInf, negInf, nan)
        }
        
        guard !value.isNaN else {
            let (_, _, nan) = try nonConformingStrings()
            return .string(name: name, string: nan)
        }
        
        guard !value.isInfinite else {
            let (pos, neg, _) = try nonConformingStrings()
            if value < 0.0 {
                return .string(name: name, string: neg)
            } else {
                return .string(name: name, string: pos)
            }
        }
        
        let formatter = XMLFloatingPointFormatter<T>()
        let string = try formatter.string(from: value)
        
        return .string(name: name, string: string)
    }
    
    func box(string value: String, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        return try self.withCodingPath(appending: key) {
            try self.boxWithoutAffectingCodingPath(string: value, forKey: key)
        }
    }

    func boxWithoutAffectingCodingPath(string value: String, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        let name = self.resolve(encodingKey: key)

        let formatter = XMLStringFormatter()
        let string = try formatter.string(from: value)

        return .string(name: name, string: string)
    }
    
    func box<T: Encodable>(encodable value: T, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        return try self.withCodingPath(appending: key) {
            try self.boxWithoutAffectingCodingPath(encodable: value, forKey: key)
        }
    }
    
    func boxWithoutAffectingCodingPath<T: Encodable>(encodable value: T, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        if T.self == Date.self || T.self == NSDate.self {
            return try self.boxWithoutAffectingCodingPath(date: value as! Date, forKey: key)
        } else if T.self == Data.self || T.self == NSData.self {
            return try self.boxWithoutAffectingCodingPath(data: value as! Data, forKey: key)
        } else if T.self == URL.self || T.self == NSURL.self {
            return try self.boxWithoutAffectingCodingPath(url: value as! URL, forKey: key)
        } else if T.self == Decimal.self || T.self == NSDecimalNumber.self {
            return try self.boxWithoutAffectingCodingPath(decimal: value as! Decimal, forKey: key)
        }
        
        try value.encode(to: self)
        
        guard let container = self.storage.popContainer() else {
            let name = self.resolve(encodingKey: key)
            return .empty(name: name)
        }
        
        return container
    }
    
    // MARK: - Internal:

    func box(decimal value: Decimal, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        return try self.withCodingPath(appending: key) {
            try self.boxWithoutAffectingCodingPath(decimal: value, forKey: key)
        }
    }

    func boxWithoutAffectingCodingPath(decimal value: Decimal, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        let name = self.resolve(encodingKey: key)
        
        let formatter = XMLDecimalFormatter()
        let string = try formatter.string(from: value)
        
        return .string(name: name, string: string)
    }

    func box(date value: Date, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        return try self.withCodingPath(appending: key) {
            try self.boxWithoutAffectingCodingPath(date: value, forKey: key)
        }
    }

    func boxWithoutAffectingCodingPath(date value: Date, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        let name = self.resolve(encodingKey: key)
        
        switch self.options.dateEncodingStrategy {
        case .deferredToDate:
            try value.encode(to: self)
            return self.storage.popContainerUnchecked()
        case .secondsSince1970:
            let formatter = XMLDateFormatter(format: .secondsSince1970)
            let string = try formatter.string(from: value)

            return .string(name: name, string: string)
        case .millisecondsSince1970:
            let formatter = XMLDateFormatter(format: .millisecondsSince1970)
            let string = try formatter.string(from: value)
            
            return .string(name: name, string: string)
        case .iso8601:
            let formatter = XMLDateFormatter(format: .iso8601)
            let string = try formatter.string(from: value)
            
            return .string(name: name, string: string)
        case .formatted(let formatter):
            let formatter = XMLDateFormatter(format: .formatter(formatter))
            let string = try formatter.string(from: value)
            
            return .string(name: name, string: string)
        case .custom(let closure):
            let depth = self.storage.count
            try closure(value, self)
            
            // The top container should be a new container.
            guard self.storage.count > depth else {
                return .empty(name: name)
            }
            
            return self.storage.popContainerUnchecked()
        }
    }

    func box(data value: Data, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        return try self.withCodingPath(appending: key) {
            try self.boxWithoutAffectingCodingPath(data: value, forKey: key)
        }
    }

    func boxWithoutAffectingCodingPath(data value: Data, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        let name = self.resolve(encodingKey: key)
        
        switch self.options.dataEncodingStrategy {
        case .deferredToData:
            try value.encode(to: self)
            
            return self.storage.popContainerUnchecked()
        case .base64:
            let formatter = XMLDataFormatter(format: .base64)
            let string = try formatter.string(from: value)
            
            return .string(name: name, string: string)
        case .custom(let closure):
            let depth = self.storage.count
            try closure(value, self)
            
            // The top container should be a new container.
            guard self.storage.count > depth else {
                return .empty(name: name)
            }
            
            return self.storage.popContainerUnchecked()
        }
    }

    func box(url value: URL, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        return try self.withCodingPath(appending: key) {
            try self.boxWithoutAffectingCodingPath(url: value, forKey: key)
        }
    }

    func boxWithoutAffectingCodingPath(url value: URL, forKey key: CodingKey) throws -> XMLElementNode {
        print("📍 @ \(#function) -> value: \"\(value)\", key: \"\(StringConvertibleCodingKey(key))\"")

        let name = self.resolve(encodingKey: key)
        
        let formatter = XMLURLFormatter()
        let string = try formatter.string(from: value)
        
        return .string(name: name, string: string)
    }
}
