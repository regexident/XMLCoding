import Foundation

public protocol XMLVisitor {
    func enter(document: XMLDocumentNode) throws
    func exitDocument() throws
    
    func enter(element: XMLElementNodeInfo, attributes: [String: String]?) throws
    func exit(element: XMLElementNodeInfo) throws
    
    func visit(element: XMLElementNodeInfo, attributes: [String: String]?) throws
    
    func visit(string: String) throws
    func visit(data: Data) throws
}

public protocol XMLVisitable {
    associatedtype Output
    
    func accept<T: XMLVisitor>(visitor: T) throws -> Output
}
