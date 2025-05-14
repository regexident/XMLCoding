# XMLCoding

A clean and modular implementation of the `Codable` protocol for XML, consisting of:

- [XMLReader](Sources/XMLReader): An efficient XML reader, based on Foundation's [`XMLParser`](https://developer.apple.com/documentation/foundation/xmlparser).
- [XMLWriter](Sources/XMLWriter): An efficient visitor-based XML writer.
- [XMLFormatter](Sources/XMLFormatter): An efficient XML formatter.
- [XMLDocument](Sources/XMLDocument): A type-safe XML document abstraction.
- [XMLCoding](Sources/XMLCoding): Efficient, yet flexible implementations of XML encoders/decoders.

## Single Value Container

> ☢️ Node-encodings are NOT applicable when coding with single value containers

```swift
struct SingleValueContainer: Codable {
    let value: Int

    init(value: Int) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(Int.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}
```

```swift
typealias Value = SingleValueContainer

let value = Value(value: 42)

let encoder = XMLEncoder()
encoder.outputFormatting = [.prettyPrinted]

let encoded = try! encoder.encode(value, rootKey: "root")
let string = String(data: encoded, encoding: .utf8)!

let decoder = XMLDecoder
let decoded = try! Value(from: decoder)
```

```xml
<root>42</root>
```

## Keyed Container

```swift
struct KeyedContainer: Codable {
    enum CodingKeys: CodingKey {
        case values
    }
    
    let values: [String: Int]

    init(values: [String: Int]) {
        self.values = values
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.values = try container.decode([String: Int].self, forKey: .values)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.values)
    }
}
```

> 💡 Node-encodings are applicable when coding with keyed  containers

```swift
typealias Value = KeyedContainer

let value = Value(values: ["foo": 1, "bar": 2])

let encoder = XMLEncoder()
encoder.outputFormatting = [.prettyPrinted]

let encoded = try! encoder.encode(value, rootKey: "root")
let string = String(data: encoded, encoding: .utf8)!

let decoder = XMLDecoder()
let decoded = try! Value(from: decoder)
```

```xml
<root>
    <foo>1</foo>
    <bar>2</bar>
</root>
```

## Unkeyed Container

```swift
struct UnkeyedContainer: Codable {
    enum CodingKeys: CodingKey {
        case values
    }

    @XMLElement()
    let values: [Int]

    init(values: [Int]) {
        self.values = values
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.values = try container.decode([Int].self, forKey: .values)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.values)
    }
}

extension UnkeyedContainer: XMLCustomNodeEncodable {
    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch
    }
}
```

> ☢️ Node-encodings are NOT applicable when coding with unkeyed  containers

```swift
typealias Value = KeyedContainer

let value = Value(values: ["foo": 1, "bar": 2])

let encoder = XMLEncoder()
encoder.outputFormatting = [.prettyPrinted]

let encoded = try! encoder.encode(value, rootKey: "root")
let string = String(data: encoded, encoding: .utf8)!

let decoder = XMLDecoder()
let decoded = try! Value(from: decoder)
```

```xml
<root>
    <foo>1</foo>
    <bar>2</bar>
</root>
```

> ☢️ Node-encodings are not applicable within unkeyed containers
