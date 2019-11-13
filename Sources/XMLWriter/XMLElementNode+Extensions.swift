import Foundation

import XMLDocument

extension XMLElementNode {
    @objc private func debugQuickLookObject() -> AnyObject {
        return NSString(string: self.debugDescription) //  self.debugDescription as NSString
    }
}

extension XMLElementNode: CustomDebugStringConvertible {
    public var debugDescription: String {
        let stream = OutputStream.toMemory()
        let writer = XMLWriter(stream: stream, formatting: .prettyPrinted(.spaces(4)))
        
        try! writer.write(fragment: self)
        
        return stream.inMemoryString!
    }
}
