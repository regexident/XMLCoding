import Foundation

public struct XMLMixedContent: Equatable {
    public var items: [XMLMixedContentItem] = []
}

public enum XMLMixedContentItem: Equatable {
    case string(String)
    case data(Data)
    case element(XMLElementNode)
    
    public var string: String? {
        guard case .string(let string) = self else {
            return nil
        }
        return string
    }
    
    public var data: Data? {
        guard case .data(let data) = self else {
            return nil
        }
        return data
    }
    
    public var element: XMLElementNode? {
        guard case .element(let element) = self else {
            return nil
        }
        return element
    }
    
    public init(simple: XMLSimpleContent) {
        switch simple {
        case .string(let string):
            self = .string(string)
        case .data(let data):
            self = .data(data)
        }
    }
}
