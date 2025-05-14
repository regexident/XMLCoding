import Foundation

struct XMLInternalCodingKey: CodingKey {
    public let stringValue: String
    public let intValue: Int?
    
    static let `super` = XMLInternalCodingKey(stringValue: "super")!
    
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

struct StringConvertibleCodingKey {
    let codingKey: CodingKey

    var stringValue: String {
        return self.codingKey.stringValue
    }

    var intValue: Int? {
        return self.codingKey.intValue
    }

    init(_ codingKey: CodingKey) {
        self.codingKey = codingKey
    }
}

extension StringConvertibleCodingKey: CustomStringConvertible {
    var description: String {
        guard let intValue = self.intValue else {
            return self.stringValue
        }
        return intValue.description
    }
}

extension StringConvertibleCodingKey: CustomDebugStringConvertible {
    var debugDescription: String {
        let typeName = String(describing: type(of: self))
        let stringValue = self.stringValue
        let intValue = self.intValue.map { "\($0)" } ?? "nil"
        return "<\(typeName) stringValue: \"\(stringValue)\", intValue: \(intValue)>"
    }
}
