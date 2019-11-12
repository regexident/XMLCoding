import Foundation

internal struct XMLEncodingKey {
    public let key: String
    public let xmlKey: String
    
    internal static let unkeyedContainerKey: XMLEncodingKey = .init(
        key: "!!!unkeyed!!!",
        xmlKey: "!!!unkeyed!!!"
    )
    
    private init(key: String, xmlKey: String) {
        self.key = key
        self.xmlKey = key
    }
    
    public init(key: CodingKey, at codingPath: [CodingKey], keyEncodingStrategy: XMLEncoder.KeyEncodingStrategy) {
        assert(!(key is XMLEncodingKey))
        switch keyEncodingStrategy {
        case .useDefaultKeys:
            self.init(key: key.stringValue, xmlKey: key.stringValue)
        case .convertToSnakeCase:
            let xmlKey = XMLEncoder.KeyEncodingStrategy._convertToSnakeCase(key.stringValue)
            self.init(key: key.stringValue, xmlKey: xmlKey)
        case .custom(let converter):
            let xmlKey = converter(codingPath + [key]).stringValue
            self.init(key: key.stringValue, xmlKey: xmlKey)
        }
    }
}
