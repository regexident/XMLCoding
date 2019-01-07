import Foundation

/// State machine determining element population:
///
/// ```
/// digraph {
///     node [shape="circle"]
///
///     empty -> simple [label="string | data"];
///     empty -> complex [label="element"];
///
///     simple -> mixed [label="string | data | element"];
///
///     complex -> mixed [label="string | data"];
///     complex -> complex [label="element"];
///
///     mixed -> mixed [label="string | data | element"];
/// }
/// ```
public enum XMLElementNodeContent: Equatable {
    case empty(XMLEmptyContent)
    case simple(XMLSimpleContent)
    case complex(XMLComplexContent)
    case mixed(XMLMixedContent)
    
    public var isEmpty: Bool {
        guard case .empty(_) = self else {
            return false
        }
        return true
    }
    
    public var isSimple: Bool {
        guard case .simple(_) = self else {
            return false
        }
        return true
    }
    
    public var isComplex: Bool {
        guard case .complex(_) = self else {
            return false
        }
        return true
    }
    
    public var isMixed: Bool {
        guard case .mixed(_) = self else {
            return false
        }
        return true
    }
    
    public var string: String? {
        guard case .simple(.string(let string)) = self else {
            return nil
        }
        return string
    }
    
    public var data: Data? {
        guard case .simple(.data(let data)) = self else {
            return nil
        }
        return data
    }
    
    public var elements: [XMLElementNode]? {
        guard case .complex(let content) = self else {
            return nil
        }
        return content.elements
    }
    
    public var items: [XMLMixedContentItem]? {
        guard case .mixed(let content) = self else {
            return nil
        }
        return content.items
    }
    
    public mutating func append(string: String) {
        switch self {
        case .empty(_):
            self = .simple(.string(string))
        case .simple(let content):
            self = .mixed(XMLMixedContent(
                items: [
                    XMLMixedContentItem(simple: content),
                    .string(string),
                ]
            ))
        case .complex(let content):
            var items: [XMLMixedContentItem] = content.elements.map { .element($0) }
            items.append(.string(string))
            self = .mixed(XMLMixedContent(
                items: items
            ))
        case .mixed(var content):
            content.items.append(.string(string))
            self = .mixed(content)
        }
    }
    
    public mutating func append(data: Data) {
        switch self {
        case .empty(_):
            self = .simple(.data(data))
        case .simple(let content):
            self = .mixed(XMLMixedContent(
                items: [
                    XMLMixedContentItem(simple: content),
                    .data(data),
                ]
            ))
        case .complex(let content):
            var items: [XMLMixedContentItem] = content.elements.map { .element($0) }
            items.append(.data(data))
            self = .mixed(XMLMixedContent(
                items: items
            ))
        case .mixed(var content):
            content.items.append(.data(data))
            self = .mixed(content)
        }
    }
    
    public mutating func append(element: XMLElementNode) {
        switch self {
        case .empty(_):
            self = .complex(XMLComplexContent(
                elements: [element]
            ))
        case .simple(let content):
            self = .mixed(XMLMixedContent(
                items: [
                    XMLMixedContentItem(simple: content),
                    .element(element),
                ]
            ))
        case .complex(var content):
            content.elements.append(element)
            self = .complex(content)
        case .mixed(var content):
            content.items.append(.element(element))
            self = .mixed(content)
        }
    }
}
