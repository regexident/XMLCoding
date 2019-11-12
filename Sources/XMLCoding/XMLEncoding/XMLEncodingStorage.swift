import Foundation

import XMLDocument

internal struct XMLEncodingStorage {
    internal typealias Container = XMLElementNode
    
    /// Caution: Consider this member effectively private!
    internal private(set) var containers: [Container] = []
    
    internal var isEmpty: Bool {
        return self.containers.isEmpty
    }
    
    internal var count: Int {
        return self.containers.count
    }
    
    internal var lastContainer: Container? {
        return self.containers.last
    }
    
    internal mutating func push(container: Container) {
        self.containers.append(container)
    }
    
    internal mutating func popContainerUnchecked() -> Container {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.removeLast()
    }
    
    internal mutating func popContainer() -> Container? {
        return self.containers.popLast()
    }
}

extension XMLEncodingStorage: CustomStringConvertible {
    var description: String {
        return self.containers.map { $0.info.name }.description
    }
}
