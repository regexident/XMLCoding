//
//  XMLElementWriter.swift
//  XMLCoding
//
//  Created by Vincent Esche on 1/4/19.
//

import Foundation

// https://github.com/pentaho/pentaho-reporting/blob/87cc1e2af217aee46decc4aa2943b1145fcd16bf/libraries/libxml/src/main/java/org/pentaho/reporting/libraries/xmlns/writer/XmlWriterSupport.java

public class XMLElementWriter: NSObject {
    
//    private Map<String, String>  prefixTable
//    private Map<String, Boolean> forcedDeclTable
//    private Map<String, String>  doneDeclTable
//    private Writer output
//    private NamespaceSupport nsSupport
//    private int prefixCounter = 0

    var systemID: String? = nil
    var publicID: String? = nil
    var allowedExternalEntityURLs: Set<URL>? = nil
    var externalEntityResolvingPolicy: XMLParser.ExternalEntityResolvingPolicy = .never

    fileprivate var namespaces: [String: String] = [:]
   
    fileprivate var stream: OutputStream
    fileprivate var elementLevel: Int = 0
    
    static let attributeEscapingCharacterSet = [
        ("&", "&amp;"),
        ("<", "&lt;"),
        (">", "&gt;"),
        ("'", "&apos;"),
        ("\"", "&quot;"),
    ]
    
    static let elementEscapingCharacterSet = [
        ("&", "&amp;"),
        ("<", "&lt;"),
        (">", "&gt;"),
    ]
    
    public init(stream: OutputStream) {
        self.stream = stream
        self.stream.open()
    }
    
    deinit {
        self.stream.close()
    }
    
    public func write(document: XMLDocument) throws {
        try document.accept(visitor: self)
    }
    
    public func write(fragment: XMLElementNode) throws {
        try fragment.accept(visitor: self)
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
        // FIXME: Enable namespaces by uncommenting:
//        let prefix = namespaceURI.flatMap { self.namespace(forURI: $0) }
//        if let prefix = prefix {
//            try self.write(raw: prefix)
//            try self.write(raw: ":")
//        }
        try self.write(raw: name)
    }
    
    fileprivate func write(attributes: [String: String]) throws {
        for (name, value) in attributes {
            let escapedValue = value.escaped(XMLElementWriter.attributeEscapingCharacterSet)
            
            try self.write(raw: " ")
            try self.write(name: name)
            try self.write(raw: "=\"")
            try self.write(raw: escapedValue)
            try self.write(raw: "\"")
        }
    }

    // FIXME: Enable namespaces by uncommenting:
//    fileprivate func add(namespace: String, forURI uri: String) {
//        self.namespaces[uri] = namespace
//    }
//
//    fileprivate func namespace(forURI uri: String) -> String? {
//        return self.namespaces[uri]
//    }
    
    internal func reset() {
        self.elementLevel = 0
//        prefixCounter = 0
//        nsSupport.reset()
    }
    
//    /**
//     * Force a Namespace to be declared on the root element.
//     *
//     * <p>By default, the XMLWriter will declare only the Namespaces
//     * needed for an element; as a result, a Namespace may be
//     * declared many places in a document if it is not used on the
//     * root element.</p>
//     *
//     * <p>This method forces a Namespace to be declared on the root
//     * element even if it is not used there, and reduces the number
//     * of xmlns attributes in the document.</p>
//     *
//     * @param uri The Namespace URI to declare.
//     * @see #forceNSDecl(java.lang.String,java.lang.String)
//     * @see #setPrefix
//     */
//    public void forceNSDecl (String uri) {
//    forcedDeclTable.put(uri, Boolean.TRUE)
//    }
//
//    /**
//     * Force a Namespace declaration with a preferred prefix.
//     *
//     * <p>This is a convenience method that invokes {@link
//     * #setPrefix setPrefix} then {@link #forceNSDecl(java.lang.String)
//     * forceNSDecl}.</p>
//     *
//     * @param uri The Namespace URI to declare on the root element.
//     * @param prefix The preferred prefix for the Namespace, or ""
//     *        for the default Namespace.
//     * @see #setPrefix
//     * @see #forceNSDecl(java.lang.String)
//     */
//    public void forceNSDecl (String uri, String prefix) {
//        setPrefix(uri, prefix)
//        forceNSDecl(uri)
//    }
//
//    /**
//     * Force all Namespaces to be declared.
//     *
//     * This method is used on the root element to ensure that
//     * the predeclared Namespaces all appear.
//     */
//    private void forceNSDecls () {
//        for (String prefix : forcedDeclTable.keySet()) {
//            doPrefix(prefix, null, true)
//        }
//    }
//
//    /**
//     * Determine the prefix for an element or attribute name.
//     *
//     * TODO: this method probably needs some cleanup.
//     *
//     * @param uri The Namespace URI.
//     * @param qName The qualified name (optional); this will be used
//     *        to indicate the preferred prefix if none is currently
//     *        bound.
//     * @param isElement true if this is an element name, false
//     *        if it is an attribute name (which cannot use the
//     *        default Namespace).
//     */
//    private String doPrefix (String uri, String qName, boolean isElement) {
//    String defaultNS = nsSupport.getURI("")
//    if ("".equals(uri)) {
//        if (isElement && defaultNS != null)
//        nsSupport.declarePrefix("", "")
//        return null
//    }
//    String prefix
//    if (isElement && defaultNS != null && uri.equals(defaultNS)) {
//        prefix = ""
//    } else {
//        prefix = nsSupport.getPrefix(uri)
//    }
//    if (prefix != null) {
//        return prefix
//    }
//    prefix = doneDeclTable.get(uri)
//    if (prefix != null &&
//        ((!isElement || defaultNS != null) &&
//         "".equals(prefix) || nsSupport.getURI(prefix) != null)) {
//        prefix = null
//    }
//    if (prefix == null) {
//        prefix = prefixTable.get(uri)
//        if (prefix != null &&
//        ((!isElement || defaultNS != null) &&
//         "".equals(prefix) || nsSupport.getURI(prefix) != null)) {
//        prefix = null
//        }
//    }
//    if (prefix == null && qName != null && !"".equals(qName)) {
//        int i = qName.indexOf(':')
//        if (i == -1) {
//        if (isElement && defaultNS == null) {
//            prefix = ""
//        }
//        } else {
//        prefix = qName.substring(0, i)
//        }
//    }
//    for (
//         prefix == null || nsSupport.getURI(prefix) != null
//         prefix = "__NS" + ++prefixCounter)
//
//    nsSupport.declarePrefix(prefix, uri)
//    doneDeclTable.put(uri, prefix)
//    return prefix
//    }
//
    
    internal func writeNamespaceDeclarations() throws {
//        Enumeration prefixes = nsSupport.getDeclaredPrefixes()
//        while (prefixes.hasMoreElements()) {
//            String prefix = (String) prefixes.nextElement()
//            String uri = nsSupport.getURI(prefix)
//            if (uri == null) {
//                uri = ""
//            }
//            try self.write(" ")
//            if ("".equals(prefix)) {
//                try self.write("xmlns=\"")
//            } else {
//                try self.write("xmlns:")
//                try self.write(prefix)
//                try self.write("=\"")
//            }
//            try self.write(uri.escaped(XMLElementWriter.escapedCharacterSet))
//            try self.write("\"")
//        }
    }
    
    internal func writeStartOfDocument(header: XMLDocumentHeader?) throws {
        self.reset()
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
        self.elementLevel += 1
//        nsSupport.pushContext()
        try self.write(raw: "<")
        try self.write(
            name: info.name,
            namespaceURI: info.namespaceURI,
            qualifiedName: info.qualifiedName
        )
        if let attributes = attributes {
            try self.write(attributes: attributes)
        }
//        if self.elementLevel == 1 {
//            self.forceNSDecls()
//        }
        try self.writeNamespaceDeclarations()
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
//        if self.elementLevel == 1 {
//            try self.write(raw: "\n")
//        }
//        nsSupport.popContext()
        self.elementLevel -= 1
    }

    internal func write(
        empty info: XMLElementNodeInfo,
        attributes: [String: String]? = nil
    ) throws {
//        nsSupport.pushContext()
        try self.write(raw: "<")
        try self.write(
            name: info.name,
            namespaceURI: info.namespaceURI,
            qualifiedName: info.qualifiedName
        )
        if let attributes = attributes {
            try self.write(attributes: attributes)
        }
//        if self.elementLevel == 1 {
//            forceNSDecls()
//        }
        try self.writeNamespaceDeclarations()
        try self.write(raw: "/>")
    }
    
    internal func write(comment: String) throws {
        let escapedComment = comment.escaped(XMLElementWriter.elementEscapingCharacterSet)
        
        try self.write(raw: "<!-- ")
        try self.write(raw: escapedComment)
        try self.write(raw: " -->")
    }
    
    internal func write(whitespace whitespaceString: String) throws {
        // FIXME: Check for whitespace-ness, before writing:
        try self.write(raw: whitespaceString)
    }
    
    internal func write(string: String) throws {
        let escapedString = string.escaped(XMLElementWriter.elementEscapingCharacterSet)
        try self.write(raw: escapedString)
    }
    
    internal func write(data: Data) throws {
        let string = String(data: data, encoding: .utf8)!
        // FIXME: enable check:
//        guard !string.contains("]]>") else {
//            fatalError()
//        }
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
//        if self.elementLevel < 1 {
//            try self.write(raw: "\n")
//        }
    }
}
