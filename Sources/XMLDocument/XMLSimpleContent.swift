import Foundation

public enum XMLSimpleContent: Equatable {
    case string(String)
    case data(Data)
    
    public var string: String? {
        guard case let .string(string) = self else {
            return nil
        }
        return string
    }
    
    public var data: Data? {
        guard case let .data(data) = self else {
            return nil
        }
        return data
    }
}
