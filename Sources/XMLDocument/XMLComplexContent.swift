import Foundation

public struct XMLComplexContent: Equatable {
    public var elements: [XMLElementNode] = []
    
    public var count: Int {
        return self.elements.count
    }
    
    public init(elements: [XMLElementNode]) {
        self.elements = elements
    }
}
