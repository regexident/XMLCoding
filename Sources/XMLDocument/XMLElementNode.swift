import Foundation

public struct XMLElementNodeInfo: Equatable {
    public var name: String
    public var namespaceURI: String?
    public var qualifiedName: String?
    
    init(
        name: String,
        namespaceURI: String? = nil,
        qualifiedName: String? = nil
    ) {
        self.name = name
        self.namespaceURI = namespaceURI
        self.qualifiedName = qualifiedName
    }
}

public final class XMLElementNode {
    public var info: XMLElementNodeInfo
    public var attributes: [String: String]
    public var content: XMLElementNodeContent
    
    public init(
        info: XMLElementNodeInfo,
        attributes: [String: String],
        content: XMLElementNodeContent
    ) {
        self.info = info
        self.attributes = attributes
        self.content = content
    }
    
    public convenience init(
        name: String,
        attributes: [String: String],
        content: XMLElementNodeContent
    ) {
        self.init(
            info: XMLElementNodeInfo(name: name),
            attributes: attributes,
            content: content
        )
    }
    
    public static func empty(name: String, attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            name: name,
            attributes: attributes,
            content: .empty(XMLEmptyContent())
        )
    }
    
    public static func string(name: String, string: String, attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            name: name,
            attributes: attributes,
            content: .simple(.string(string))
        )
    }
    
    public static func data(name: String, data: Data, attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            name: name,
            attributes: attributes,
            content: .simple(.data(data))
        )
    }
    
    public static func complex(name: String, elements: [XMLElementNode], attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            name: name,
            attributes: attributes,
            content: .complex(XMLComplexContent(elements: elements))
        )
    }
    
    public static func mixed(name: String, items: [XMLMixedContentItem], attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            name: name,
            attributes: attributes,
            content: .mixed(XMLMixedContent(items: items))
        )
    }
    
    public func append(string: String) {
        self.content.append(string: string)
    }
    
    public func append(data: Data) {
        self.content.append(data: data)
    }
    
    public func append(element: XMLElementNode) {
        self.content.append(element: element)
    }
}

extension XMLElementNode: Equatable {
    public static func == (lhs: XMLElementNode, rhs: XMLElementNode) -> Bool {
        guard lhs.info == rhs.info else {
            return false
        }
        guard lhs.attributes == rhs.attributes else {
            return false
        }
        guard lhs.content == rhs.content else {
            return false
        }
        return true
    }
}

extension XMLElementNode: XMLVisitable {
    public typealias Output = ()
    
    public func accept<T: XMLVisitor>(visitor: T) throws -> () {
        let info = self.info
        let attributes = self.attributes
        switch self.content {
        case .empty:
            try visitor.visit(element: info, content: nil, attributes: attributes)
        case .simple(let content):
            try visitor.visit(element: info, content: content, attributes: attributes)
        case .complex(let content):
            try visitor.enter(element: info, attributes: attributes)
            for element in content.elements {
                try element.accept(visitor: visitor)
            }
            try visitor.exit(element: info)
        case .mixed(let content):
            try visitor.enter(element: info, attributes: attributes)
            for item in content.items {
                switch item {
                case .string(let string):
                    try visitor.visit(string: string)
                case .data(let data):
                    try visitor.visit(data: data)
                case .element(let element):
                    try element.accept(visitor: visitor)
                }
            }
            try visitor.exit(element: info)
        }
    }
}
