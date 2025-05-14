import Foundation

import XMLDocument

extension XMLElementNode {
    func flatten() {
        switch self.content {
        case .empty(let content):
            self.content = .empty(content)
        case .simple(let content):
            self.content = .simple(content)
        case .complex(var content):
            content.elements = content.elements.filter { element in
                !element.info.name.isEmpty
            }
            self.content = .complex(content)
        case .mixed(var content):
            content.items = content.items.filter { item in
                guard case .element(let element) = item else {
                    return false
                }
                return !element.info.name.isEmpty
            }
            self.content = .mixed(content)
        }
    }
    
    func sortByKeys(recursively: Bool = true) {
        guard case .complex(var content) = self.content else {
            return
        }
        if recursively {
            for element in content.elements {
                element.sortByKeys(recursively: recursively)
            }
        }
        content.elements.sort { lhs, rhs in
            lhs.info.name < rhs.info.name
        }
        self.content = .complex(content)
    }
}
