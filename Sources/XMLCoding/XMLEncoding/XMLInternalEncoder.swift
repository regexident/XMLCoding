import Foundation

import XMLDocument
import XMLFormatter

internal class XMLInternalEncoder: Encoder {
    internal typealias Container = XMLEncodingStorage.Container
    
    /// The encoded document's root key.
    private let rootKey: CodingKey
    
    /// The encoder's storage.
    private var storage: XMLEncodingStorage
    
    /// Options set on the top-level encoder.
    internal let options: XMLEncoder._Options
    
    /// The path to the current point in encoding.
    public var codingPath: [CodingKey] {
        didSet {
            let before = oldValue.map { $0.stringValue }.joined(separator: ".")
            let after = self.codingPath.map { $0.stringValue }.joined(separator: ".")
            if oldValue.count < self.codingPath.count {
                print("🔶: \"\(before)\" -> \"\(after)\"")
            } else {
                print("🔶: \"\(before)\" -> \"\(after)\"")
            }
            if oldValue.last?.stringValue == self.codingPath.last?.stringValue {
                print("🔶 !!!")
            }
        }
    }
    
    public var nodeEncodings: [(CodingKey) -> XMLEncoder.NodeEncoding]
    
    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] {
        return self.options.userInfo
    }
    
    internal var containerStackCount: Int {
        return self.storage.count
    }
    
    /// Initializes `self` with the given top-level encoder options.
    internal init(
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
    
    internal func with<T>(codingPath: [CodingKey], _ closure: (XMLInternalEncoder) throws -> T) rethrows -> T {
        let previousCodingPath = self.codingPath
        defer {
            // Reset to previous value when done:
            self.codingPath = previousCodingPath
        }
        self.codingPath = codingPath
        return try closure(self)
    }
    
    internal func resolve(encodingKey codingKey: CodingKey) -> String {
        let encodingKey = XMLEncodingKey(
            key: codingKey,
            at: self.codingPath,
            keyEncodingStrategy: self.options.keyEncodingStrategy
        )
        
        return encodingKey.xmlKey
    }
    
    internal func push(container: Container) {
        self.storage.push(container: container)
    }
    
//    internal func popContainerUnchecked() -> Container {
//        return self.storage.popContainerUnchecked()
//    }
    
    internal func popContainer() -> Container? {
        return self.storage.popContainer()
    }
    
    /// Returns whether a new element can be encoded at this coding path.
    ///
    /// `true` if an element has not yet been encoded at this coding path; `false` otherwise.
    internal var canEncodeNewValue: Bool {
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
        
        return (self.storage.count - 1) <= self.codingPath.count
    }
    
    public func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> {
        let codingKey = self.codingPath.last ?? self.rootKey
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
        let codingKey = self.codingPath.last ?? self.rootKey
        let name = self.resolve(encodingKey: codingKey)
        let container = XMLElementNode.empty(name: name)
        self.storage.push(container: container)
        
        guard let topContainer = self.storage.lastContainer else {
            preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
        }
        
        return XMLUnkeyedEncodingContainer(
            key: self.codingPath.last!,
            referencing: self,
            codingPath: self.codingPath,
            wrapping: topContainer
        )
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return XMLSingleValueEncodingContainer(
            key: self.codingPath.last ?? self.rootKey,
            referencing: self,
            codingPath: self.codingPath
        )
    }
}

// MARK: - Boxing:

extension XMLInternalEncoder {
    // MARK: - Public:
    
    internal func box(null: (), forKey key: CodingKey) throws -> XMLElementNode {
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
        let name = self.resolve(encodingKey: key)
        
        return .empty(name: name)
    }
    
    internal func box(bool value: Bool, forKey key: CodingKey) throws -> XMLElementNode {
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
        let name = self.resolve(encodingKey: key)
        
        let formatter = XMLBoolFormatter()
        let string = try formatter.string(from: value)
        
        return .string(name: name, string: string)
    }
    
    internal func box<T: FixedWidthInteger>(integer value: T, forKey key: CodingKey) throws -> XMLElementNode {
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
        let name = self.resolve(encodingKey: key)
        
        let formatter = XMLIntegerFormatter<T>()
        let string = try formatter.string(from: value)
        
        return .string(name: name, string: string)
    }
    
    internal func box<T: FixedWidthFloatingPoint>(floatingPoint value: T, forKey key: CodingKey) throws -> XMLElementNode {
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
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
    
    internal func box(string value: String, forKey key: CodingKey) throws -> XMLElementNode {
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
        let name = self.resolve(encodingKey: key)
        
        let formatter = XMLStringFormatter()
        let string = try formatter.string(from: value)
        
        return .string(name: name, string: string)
    }
    
    internal func box<T: Encodable>(encodable value: T, forKey key: CodingKey) throws -> XMLElementNode {
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
        return try self.boxWithoutAffectingCodingPath(encodable: value, forKey: key)
    }
    
    internal func boxWithoutAffectingCodingPath<T: Encodable>(encodable value: T, forKey key: CodingKey) throws -> XMLElementNode {
        if T.self == Date.self || T.self == NSDate.self {
            return try self.box(date: value as! Date, forKey: key)
        } else if T.self == Data.self || T.self == NSData.self {
            return try self.box(data: value as! Data, forKey: key)
        } else if T.self == URL.self || T.self == NSURL.self {
            return try self.box(url: value as! URL, forKey: key)
        } else if T.self == Decimal.self || T.self == NSDecimalNumber.self {
            return try self.box(decimal: value as! Decimal, forKey: key)
        }
        
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
        try value.encode(to: self)
        
        guard let container = self.storage.popContainer() else {
            let name = self.resolve(encodingKey: key)
            return .empty(name: name)
        }
        
        return container
    }
    
    // MARK: - Internal:
    
    internal func box(decimal value: Decimal, forKey key: CodingKey) throws -> XMLElementNode {
        let name = self.resolve(encodingKey: key)
        
        let formatter = XMLDecimalFormatter()
        let string = try formatter.string(from: value)
        
        return .string(name: name, string: string)
    }
    
    internal func box(date value: Date, forKey key: CodingKey) throws -> XMLElementNode {
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
    
    internal func box(data value: Data, forKey key: CodingKey) throws -> XMLElementNode {
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
    
    internal func box(url value: URL, forKey key: CodingKey) throws -> XMLElementNode {
        let name = self.resolve(encodingKey: key)
        
        let formatter = XMLURLFormatter()
        let string = try formatter.string(from: value)
        
        return .string(name: name, string: string)
    }
}
