import Foundation

import XMLDocument
import XMLFormatter
import XMLWriter

public class XMLEncoder {
    /// The formatting of the output XML data.
    public typealias OutputFormatting = XMLOutputFormatting
    
    /// A node's encoding tyoe
    public typealias NodeEncoding = XMLNodeEncoding
    
    /// The strategy to use for encoding `Date` values.
    public typealias DateEncodingStrategy = XMLDateEncodingStrategy
    
    /// The strategy to use for encoding `String` values.
    public typealias StringEncodingStrategy = XMLStringEncodingStrategy
    
    /// The strategy to use for encoding `Data` values.
    public typealias DataEncodingStrategy = XMLDataEncodingStrategy
    
    /// The strategy to use for non-XML-conforming floating-point values (IEEE 754 infinity and NaN).
    public typealias NonConformingFloatEncodingStrategy = XMLNonConformingFloatEncodingStrategy
    
    /// The strategy to use for automatically changing the value of keys before encoding.
    public typealias KeyEncodingStrategy = XMLKeyEncodingStrategy
    
    @available(*, deprecated, renamed: "NodeEncodingStrategy")
    public typealias NodeEncodingStrategies = NodeEncodingStrategy
    
    /// Set of strategies to use for encoding of nodes.
    public typealias NodeEncodingStrategy = XMLNodeEncodingStrategy
    
    /// The output format to produce. Defaults to `[]`.
    open var outputFormatting: OutputFormatting = []
    
    /// The strategy to use in encoding dates. Defaults to `.deferredToDate`.
    open var dateEncodingStrategy: DateEncodingStrategy = .deferredToDate
    
    /// The strategy to use in encoding binary data. Defaults to `.base64`.
    open var dataEncodingStrategy: DataEncodingStrategy = .base64
    
    /// The strategy to use in encoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy = .throw
    
    /// The strategy to use for encoding keys. Defaults to `.useDefaultKeys`.
    open var keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys
    
    /// The strategy to use in encoding encoding attributes. Defaults to `.deferredToEncoder`.
    open var nodeEncodingStrategy: NodeEncodingStrategy = .deferredToEncoder
    
    /// The strategy to use in encoding strings. Defaults to `.deferredToString`.
    open var stringEncodingStrategy: StringEncodingStrategy = .deferredToString
    
    /// Contextual user-provided information for use during encoding.
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    
    /// Options set on the top-level encoder to pass down the encoding hierarchy.
    struct _Options {
        let dateEncodingStrategy: DateEncodingStrategy
        let dataEncodingStrategy: DataEncodingStrategy
        let nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy
        let keyEncodingStrategy: KeyEncodingStrategy
        let nodeEncodingStrategy: NodeEncodingStrategy
        let stringEncodingStrategy: StringEncodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }
    
    /// The options set on the top-level encoder.
    var options: _Options {
        return _Options(
            dateEncodingStrategy: self.dateEncodingStrategy,
            dataEncodingStrategy: self.dataEncodingStrategy,
            nonConformingFloatEncodingStrategy: self.nonConformingFloatEncodingStrategy,
            keyEncodingStrategy: self.keyEncodingStrategy,
            nodeEncodingStrategy: self.nodeEncodingStrategy,
            stringEncodingStrategy: self.stringEncodingStrategy,
            userInfo: self.userInfo
        )
    }
    
    /// Initializes `self` with default strategies.
    public init() {}
    
    /// Encodes the given top-level value and returns its XML representation.
    ///
    /// - parameter value: The value to encode.
    /// - parameter rootKey: the key used to wrap the encoded values.
    /// - parameter header: the XML header.
    /// - returns: A new `Data` value containing the encoded XML data.
    /// - throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - throws: An error if any value throws an error during encoding.
    public func encode<T: Encodable>(
        _ value: T,
        rootKey: String,
        header: XMLDocumentHeader? = nil
    ) throws -> Data {
        let stream = OutputStream.toMemory()
        
        try self.encode(
            value,
            into: stream,
            rootKey: rootKey,
            header: header
        )
        
        let dataOrNil = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data
        
        guard let data = dataOrNil else {
            fatalError()
        }
        
        return data
    }
    
    public func encode<T: Encodable>(
        _ value: T,
        into stream: OutputStream,
        rootKey: String,
        header: XMLDocumentHeader? = nil
    ) throws {
        let key = XMLInternalCodingKey(key: rootKey)
        let codingPath: [CodingKey] = []
        
        let encoder = XMLInternalEncoder(
            rootKey: key,
            options: self.options,
            nodeEncodings: [],
            codingPath: codingPath
        )
        
        encoder.nodeEncodings.append(
            self.options.nodeEncodingStrategy.nodeEncodings(
                forType: T.self,
                with: encoder
            )
        )
        defer { let _ = encoder.nodeEncodings.removeLast() }
        
        let container = XMLSingleValueEncodingContainer(
            key: key,
            referencing: encoder,
            codingPath: codingPath,
            wrapping: nil
        )
        
        try container.encodeWithoutAffectingCodingPath(value)
        
        let formatting: XMLWriter.Formatting
        
        if self.outputFormatting.contains(.prettyPrinted) {
            formatting = .prettyPrinted(.spaces(4))
        } else {
            formatting = .compact
        }
        
        let writer = XMLWriter(stream: stream, formatting: formatting)
        
        let element = encoder.popContainer()! // ?? .empty(name: rootKey)
        
        if self.outputFormatting.contains(.sortedKeys) {
            element.sortByKeys()
        }
        
        let document = XMLDocumentNode(
            header: header,
            rootElement: element
        )
        
        try writer.write(document: document)
    }
}
