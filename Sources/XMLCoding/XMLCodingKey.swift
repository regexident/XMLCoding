import Foundation

struct XMLCodingKey: CodingKey {
    public let stringValue: String
    public let intValue: Int?
    
    static let `super` = XMLCodingKey(stringValue: "super")!
    
    public init?(stringValue: String) {
        self.init(stringValue: stringValue, intValue: nil)
    }
    
    public init?(intValue: Int) {
        self.init(stringValue: "Index \(intValue)", intValue: intValue)
    }
    
    public init(key: String) {
        self.init(stringValue: key, intValue: nil)
    }
    
    public init(index: Int) {
        self.init(stringValue: "Index \(index)", intValue: index)
    }
    
    private init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }
}
