import Foundation

import XMLDocument

public class XMLWriter: NSObject {
    public enum Formatting {
        case compact
        case prettyPrinted(Indentation)
        
        public static let `default`: Formatting = .compact
        
        public enum Indentation {
            case spaces(Int)
            case tabs
            
            public static let `default`: Indentation = .spaces(4)
        }
    }
    
    public let formatting: Formatting
    
    fileprivate var stream: OutputStream
    fileprivate var depthLevel: Int = 0
    fileprivate var indentations: [Int: String] = [:]
    
    fileprivate lazy var levelIndentation: String = {
        guard case .prettyPrinted(let indentation) = self.formatting else {
            return ""
        }
        switch indentation {
        case .spaces(let count):
            return String(repeating: " ", count: count)
        case .tabs:
            return "\t"
        }
    }()
    
    public init(stream: OutputStream, formatting: Formatting = .default) {
        self.stream = stream
        self.stream.open()
        self.formatting = formatting
    }
    
    deinit {
        self.stream.close()
    }
    
    public func write(document: XMLDocumentNode) throws {
        self.reset()
        try document.accept(visitor: self)
    }
    
    public func write(fragment: XMLElementNode) throws {
        self.reset()
        try fragment.accept(visitor: self)
    }
    
    internal func reset() {
        self.depthLevel = 0
    }
    
    internal func writeStartOfDocument(
        header: XMLDocumentHeader?
    ) throws {
        guard let header = header, !header.isEmpty else {
            return
        }
        
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
        
        try self.writeNewline()
    }
    
    internal func writeEndOfDocument() throws {
        try self.write(raw: "")
    }
    
    internal func write(
        start info: XMLElementNodeInfo,
        attributes: [String: String]? = nil,
        collapsed: Bool = false
    ) throws {
        try self.write(indentedRaw: "<")
        
        try self.write(
            name: info.name,
            namespaceURI: info.namespaceURI,
            qualifiedName: info.qualifiedName
        )
        
        if let attributes = attributes {
            try self.write(attributes: attributes)
        }
        
        try self.write(raw: ">")
        
        if !collapsed {
            try self.writeNewline()
        }
        
        self.depthLevel += 1
    }
    
    internal func write(
        end info: XMLElementNodeInfo,
        collapsed: Bool = false
    ) throws {
        self.depthLevel -= 1
        
        if collapsed {
            try self.write(raw: "</")
        } else {
            try self.write(indentedRaw: "</")
        }
        
        try self.write(
            name: info.name,
            namespaceURI: info.namespaceURI,
            qualifiedName: info.qualifiedName
        )
        
        try self.write(raw: ">")
        
        try self.writeNewline()
    }
    
    internal func write(
        empty info: XMLElementNodeInfo,
        attributes: [String: String]? = nil
    ) throws {
        try self.write(indentedRaw: "<")
        
        try self.write(
            name: info.name,
            namespaceURI: info.namespaceURI,
            qualifiedName: info.qualifiedName
        )
        
        if let attributes = attributes {
            try self.write(attributes: attributes)
        }
        
        try self.write(raw: "/>")
        
        try self.writeNewline()
    }
    
    internal func write(
        comment: String
    ) throws {
        let escapedComment = self.escaped(comment: comment)
        
        // FIXME: Check for forbidden "--" in `escapedComment`.
        
        try self.write(indentedRaw: "<!-- ")
        
        try self.write(raw: escapedComment)
        
        try self.write(raw: " -->")
        
        try self.writeNewline()
    }
    
    internal func write(whitespace whitespaceString: String) throws {
        // FIXME: Check for whitespace-ness, before writing.
        
        try self.write(raw: whitespaceString)
    }
    
    internal func write(
        string: String,
        collapsed: Bool = false
    ) throws {
        let escapedString = self.escaped(string: string)
        
        if collapsed {
            try self.write(raw: escapedString)
        } else {
            try self.write(indentedRaw: escapedString)
            try self.writeNewline()
        }
    }
    
    internal func write(
        data: Data,
        collapsed: Bool = false
    ) throws {
        let string = String(data: data, encoding: .utf8)!
        
        // FIXME: Check for forbidden "]]>" in `string`.
        
        let cdataBlock = "<![CDATA[\(string)]]>"
        
        if collapsed {
            try self.write(raw: cdataBlock)
        } else {
            try self.write(indentedRaw: cdataBlock)
            try self.writeNewline()
        }
    }
    
    internal func write(
        processingInstruction: XMLProcessingInstruction
    ) throws {
        try self.write(raw: "<?")
        
        try self.write(raw: processingInstruction.target)
        
        try self.write(raw: " ")
        
        if let value = processingInstruction.value {
            try self.write(raw: value)
        }
        
        try self.write(raw: "?>")
        
        try self.writeNewline()
    }
    
    fileprivate func writeNewline() throws {
        guard case .prettyPrinted = self.formatting else {
            return
        }
        try self.write(raw: "\n")
    }
    
    fileprivate func write(
        indentedRaw string: String
    ) throws {
        var indentedString = self.indentation(for: self.depthLevel)
        
        if indentedString.isEmpty {
            indentedString = string
        } else {
            indentedString += string
        }
        
        try self.write(raw: indentedString)
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
    
    fileprivate func write(
        name: String,
        namespaceURI: String? = nil,
        qualifiedName: String? = nil
    ) throws {
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
        return attribute.escaped(
            [
                ("&", "&amp;"),
                ("<", "&lt;"),
                (">", "&gt;"),
                ("'", "&apos;"),
                ("\"", "&quot;"),
            ]
        )
    }
    
    fileprivate func escaped(string: String) -> String {
        return string.escaped(
            [
                ("&", "&amp;"),
                ("<", "&lt;"),
                (">", "&gt;"),
            ]
        )
    }
    
    fileprivate func escaped(comment: String) -> String {
        return comment.escaped(
            [
                ("&", "&amp;"),
                ("<", "&lt;"),
                (">", "&gt;"),
            ]
        )
    }
    
    fileprivate func indentation(for level: Int) -> String {
//        assert(level >= 0)
        
        guard level > 0 else {
            return ""
        }
        
        if let indentation = self.indentations[level] {
            return indentation
        }
        
        let lesserIndentation = self.indentation(for: level - 1)
        let indentation = lesserIndentation + self.levelIndentation
        self.indentations[level] = indentation
        
        return indentation
    }
}
