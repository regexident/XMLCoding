import Foundation

public struct XMLComplexContent: Equatable {
    public var elements: [XMLElementNode] = []

    public init(elements: [XMLElementNode]) {
        self.elements = elements
    }
}
