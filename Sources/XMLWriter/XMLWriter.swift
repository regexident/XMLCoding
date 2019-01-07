import Foundation

import XMLDocument

public class XMLWriter: NSObject {
    fileprivate var stream: OutputStream
    
    public init(stream: OutputStream) {
        self.stream = stream
        self.stream.open()
    }
    
    deinit {
        self.stream.close()
    }
    
    public func write(document: XMLDocumentNode) throws {
        try document.accept(visitor: self)
    }
    
    public func write(fragment: XMLElementNode) throws {
        try fragment.accept(visitor: self)
    }
    
    internal func writeStartOfDocument(header: XMLDocumentHeader?) throws {
        if let header = header, !header.isEmpty {
            try self.write(raw: "<?xml")
            if let version = header.version {
                try self.write(raw: " version=\"\(version)\"")
            }
            if let encoding = header.encoding {
                try self.write(raw: " encoding=\"\(encoding)\"")
            }
            if let standalone = header.standalone {
                try self.write(raw: " standalone=\"\(standalone)\"")
            }
            try self.write(raw: " ?>")
        }
    }
    
    internal func writeEndOfDocument() throws {
        try self.write(raw: "")
    }
    
    internal func write(
        start info: XMLElementNodeInfo,
        attributes: [String: String]? = nil
    ) throws {
        try self.write(raw: "<")
        try self.write(
            name: info.name,
            namespaceURI: info.namespaceURI,
            qualifiedName: info.qualifiedName
        )
        if let attributes = attributes {
            try self.write(attributes: attributes)
        }
        try self.write(raw: ">")
    }
    
    internal func write(end info: XMLElementNodeInfo) throws {
        try self.write(raw: "</")
        try self.write(
            name: info.name,
            namespaceURI: info.namespaceURI,
            qualifiedName: info.qualifiedName
        )
        try self.write(raw: ">")
    }

    internal func write(
        empty info: XMLElementNodeInfo,
        attributes: [String: String]? = nil
    ) throws {
        try self.write(raw: "<")
        try self.write(
            name: info.name,
            namespaceURI: info.namespaceURI,
            qualifiedName: info.qualifiedName
        )
        if let attributes = attributes {
            try self.write(attributes: attributes)
        }
        try self.write(raw: "/>")
    }
    
    internal func write(comment: String) throws {
        let escapedComment = self.escaped(comment: comment)
        
        // FIXME: Check for forbidden "--" in `escapedComment`.
        
        try self.write(raw: "<!-- ")
        try self.write(raw: escapedComment)
        try self.write(raw: " -->")
    }
    
    internal func write(whitespace whitespaceString: String) throws {
        // FIXME: Check for whitespace-ness, before writing.
        
        try self.write(raw: whitespaceString)
    }
    
    internal func write(string: String) throws {
        let escapedString = self.escaped(string: string)
        try self.write(raw: escapedString)
    }
    
    internal func write(data: Data) throws {
        let string = String(data: data, encoding: .utf8)!
        
        // FIXME: Check for forbidden "]]>" in `string`.
        
        try self.write(raw: "<![CDATA[\(string)]]>")
    }
    
    internal func write(processingInstruction: XMLProcessingInstruction) throws {
        try self.write(raw: "<?")
        try self.write(raw: processingInstruction.target)
        try self.write(raw: " ")
        if let value = processingInstruction.value {
            try self.write(raw: value)
        }
        try self.write(raw: "?>")
    }
    
    fileprivate func write(raw string: String) throws {
        // Given that UTF-8 is the native internal representation
        // of String this should never fail when passed `.utf8`:
        let data = string.data(using: .utf8)!
        
        let bytesWritten = data.withUnsafeBytes { pointer in
            self.stream.write(pointer, maxLength: data.count)
        }
        
        if bytesWritten != data.count, let error = self.stream.streamError {
            throw error
        }
    }
    
    fileprivate func write(name: String, namespaceURI: String? = nil, qualifiedName: String? = nil) throws {
        try self.write(raw: name)
    }
    
    fileprivate func write(attributes: [String: String]) throws {
        for (name, value) in attributes {
            let escapedValue = self.escaped(attribute: value)
            
            try self.write(raw: " ")
            try self.write(name: name)
            try self.write(raw: "=\"")
            try self.write(raw: escapedValue)
            try self.write(raw: "\"")
        }
    }
    
    fileprivate func escaped(attribute: String) -> String {
        return attribute.escaped([
            ("&", "&amp;"),
            ("<", "&lt;"),
            (">", "&gt;"),
            ("'", "&apos;"),
            ("\"", "&quot;"),
        ])
    }
    
    fileprivate func escaped(string: String) -> String {
        return string.escaped([
            ("&", "&amp;"),
            ("<", "&lt;"),
            (">", "&gt;"),
        ])
    }
    
    fileprivate func escaped(comment: String) -> String {
        return comment.escaped([
            ("&", "&amp;"),
            ("<", "&lt;"),
            (">", "&gt;"),
        ])
    }
}
