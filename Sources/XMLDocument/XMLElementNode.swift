import Foundation

public struct XMLElementNodeInfo: Equatable {
    public var name: String
    public var namespaceURI: String? = nil
    public var qualifiedName: String? = nil
    
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

public struct XMLElementNode: Equatable {
    public var info: XMLElementNodeInfo
    public var attributes: [String: String]
    public var content: XMLElementNodeContent
    
    public static func empty(name: String, attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            info: XMLElementNodeInfo(name: name),
            attributes: attributes,
            content: .empty(XMLEmptyContent())
        )
    }
    
    public static func string(name: String, string: String, attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            info: XMLElementNodeInfo(name: name),
            attributes: attributes,
            content: .simple(.string(string))
        )
    }
    
    public static func data(name: String, data: Data, attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            info: XMLElementNodeInfo(name: name),
            attributes: attributes,
            content: .simple(.data(data))
        )
    }
    
    public static func complex(name: String, elements: [XMLElementNode], attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            info: XMLElementNodeInfo(name: name),
            attributes: attributes,
            content: .complex(XMLComplexContent(elements: elements))
        )
    }
    
    public static func mixed(name: String, items: [XMLMixedContentItem], attributes: [String: String] = [:]) -> XMLElementNode {
        return XMLElementNode(
            info: XMLElementNodeInfo(name: name),
            attributes: attributes,
            content: .mixed(XMLMixedContent(items: items))
        )
    }
    
    public mutating func append(string: String) {
        self.content.append(string: string)
    }
    
    public mutating func append(data: Data) {
        self.content.append(data: data)
    }
    
    public mutating func append(element: XMLElementNode) {
        self.content.append(element: element)
    }
}

extension XMLElementNode: XMLVisitable {
    public typealias Output = ()
    
    public func accept<T: XMLVisitor>(visitor: T) throws -> () {
        let info = self.info
        let attributes = self.attributes
        switch self.content {
        case .empty(_):
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
