import Foundation

import XMLDocument

internal class XMLReferencingEncoder: XMLInternalEncoder {
    /// The type of container we're referencing.
    private enum Reference {
        /// Referencing a specific index in an unkeyed container.
        case unkeyed(Int)
        
        /// Referencing a specific key in a keyed container.
        case keyed(String)
    }
    
    /// The encoder we're referencing.
    let encoder: XMLInternalEncoder
    
    /// The container reference itself.
    private let reference: Reference
    
    private let container: XMLElementNode
    
    /// Initializes `self` by referencing the given array container in the given encoder.
    init(
        rootKey: CodingKey,
        referencing encoder: XMLInternalEncoder,
        at index: Int,
        wrapping container: XMLElementNode
    ) {
        self.encoder = encoder
        self.reference = .unkeyed(index)
        self.container = container
        
        super.init(
            rootKey: rootKey,
            options: encoder.options,
            nodeEncodings: encoder.nodeEncodings,
            codingPath: encoder.codingPath
        )
        
        self.codingPath.append(XMLInternalCodingKey(index: index))
    }
    
    /// Initializes `self` by referencing the given dictionary container in the given encoder.
    init(
        rootKey: CodingKey,
        referencing encoder: XMLInternalEncoder,
        convertedKey: CodingKey,
        wrapping container: XMLElementNode
    ) {
        self.encoder = encoder
        self.reference = .keyed(convertedKey.stringValue)
        self.container = container
        
        super.init(
            rootKey: rootKey,
            options: encoder.options,
            nodeEncodings: encoder.nodeEncodings,
            codingPath: encoder.codingPath
        )
        
        self.codingPath.append(rootKey)
    }
    
    // MARK: - Coding Path Operations
    
    override var canEncodeNewValue: Bool {
        // With a regular encoder, the storage and coding path grow together.
        // A referencing encoder, however, inherits its parents coding path, as well as the key it was created for.
        // We have to take this into account.
        return self.encoder.containerStackCount == self.codingPath.count - self.encoder.codingPath.count - 1
    }
    
    // MARK: - Deinitialization
    
    // Finalizes `self` by writing the contents of our storage to the referenced encoder's storage.
    deinit {
        fatalError()
        
//        let element: XMLElementNode
//        switch self.storage.count {
//            // FIXME: Is it correct to pass `self.rootKey` here?
//        case 0: element = XMLElementNode.empty(name: self.rootKey)
//        case 1: element = self.storage.popContainer()
//        case _: fatalError("Referencing encoder deallocated with multiple containers on stack.")
//        }
//
//        switch self.reference {
//        case let .unkeyed(index):
//            self.container.insert(element, at: index)
//        case let .keyed(key):
//            self.container.elements[key] = element
//        }
    }
}
