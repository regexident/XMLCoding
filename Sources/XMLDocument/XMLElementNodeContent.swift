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
        guard case .empty = self else {
            return false
        }
        return true
    }
    
    public var isSimple: Bool {
        guard case .simple = self else {
            return false
        }
        return true
    }
    
    public var isComplex: Bool {
        guard case .complex = self else {
            return false
        }
        return true
    }
    
    public var isMixed: Bool {
        guard case .mixed = self else {
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
    
    public var count: Int {
        switch self {
        case .empty(let empty): return empty.count
        case .simple(let simple): return simple.count
        case .complex(let complex): return complex.count
        case .mixed(let mixed): return mixed.count
        }
    }
    
    public mutating func append(string: String) {
        self.add(string: string, via: .append)
    }
    
    public mutating func append(data: Data) {
        self.add(data: data, via: .append)
    }
    
    public mutating func append(element: XMLElementNode) {
        self.add(element: element, via: .append)
    }
    
    public mutating func insert(string: String, at index: Int) {
        self.add(string: string, via: .insert(index))
    }
    
    public mutating func insert(data: Data, at index: Int) {
        self.add(data: data, via: .insert(index))
    }
    
    public mutating func insert(element: XMLElementNode, at index: Int) {
        self.add(element: element, via: .insert(index))
    }
    
    private enum Operation {
        case append
        case insert(Int)
    }
    
    private mutating func add(string: String, via operation: Operation) {
        switch self {
        case .empty:
            let item: XMLSimpleContent = .string(string)
            self = .simple(simple(with: item, via: operation))
        case .simple(let content):
            let item = XMLMixedContentItem.string(string)
            let items = [XMLMixedContentItem(simple: content)]
            self = .mixed(mixed(adding: item, to: items, via: operation))
        case .complex(let content):
            let item = XMLMixedContentItem.string(string)
            let items: [XMLMixedContentItem] = content.elements.map { .element($0) }
            self = .mixed(self.mixed(adding: item, to: items, via: operation))
        case .mixed(let content):
            let item = XMLMixedContentItem.string(string)
            let items: [XMLMixedContentItem] = content.items
            self = .mixed(self.mixed(adding: item, to: items, via: operation))
        }
    }
    
    private mutating func add(data: Data, via operation: Operation) {
        switch self {
        case .empty:
            let item: XMLSimpleContent = .data(data)
            self = .simple(simple(with: item, via: operation))
        case .simple(let content):
            let item = XMLMixedContentItem.data(data)
            let items = [XMLMixedContentItem(simple: content)]
            self = .mixed(mixed(adding: item, to: items, via: operation))
        case .complex(let content):
            let item = XMLMixedContentItem.data(data)
            let items: [XMLMixedContentItem] = content.elements.map { .element($0) }
            self = .mixed(self.mixed(adding: item, to: items, via: operation))
        case .mixed(let content):
            let item = XMLMixedContentItem.data(data)
            let items: [XMLMixedContentItem] = content.items
            self = .mixed(self.mixed(adding: item, to: items, via: operation))
        }
    }
    
    private mutating func add(element: XMLElementNode, via operation: Operation) {
        switch self {
        case .empty:
            let elements: [XMLElementNode] = []
            self = .complex(complex(adding: element, to: elements, via: operation))
        case .simple(let content):
            let item = XMLMixedContentItem.element(element)
            let items = [XMLMixedContentItem(simple: content)]
            self = .mixed(mixed(adding: item, to: items, via: operation))
        case .complex(let content):
            let elements: [XMLElementNode] = content.elements
            self = .complex(self.complex(adding: element, to: elements, via: operation))
        case .mixed(let content):
            let item = XMLMixedContentItem.element(element)
            let items: [XMLMixedContentItem] = content.items
            self = .mixed(self.mixed(adding: item, to: items, via: operation))
        }
    }
    
    private func simple(with item: XMLSimpleContent, via operation: Operation) -> XMLSimpleContent {
        if case .insert(let index) = operation {
            precondition(index == 0, "Index out of bounds, expected 0, found \(index).")
        }
        return item
    }
    
    private func complex(adding element: XMLElementNode, to elements: [XMLElementNode], via operation: Operation) -> XMLComplexContent {
        var elements = elements
        switch operation {
        case .append:
            elements.append(element)
        case .insert(let index):
            precondition(
                index <= elements.count,
                "Index out of bounds, expected <=\(elements.count), found \(index)."
            )
            elements.insert(element, at: index)
        }
        return XMLComplexContent(elements: elements)
    }
    
    private func mixed(adding item: XMLMixedContentItem, to items: [XMLMixedContentItem], via operation: Operation) -> XMLMixedContent {
        var items = items
        switch operation {
        case .append:
            items.append(item)
        case .insert(let index):
            precondition(
                index <= items.count,
                "Index out of bounds, expected <=\(items.count), found \(index)."
            )
            items.insert(item, at: index)
        }
        return XMLMixedContent(items: items)
    }
}
