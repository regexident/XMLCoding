import Foundation

public enum XMLSimpleContent: Equatable {
    case string(String)
    case data(Data)
    
    public var string: String? {
        guard case .string(let string) = self else {
            return nil
        }
        return string
    }
    
    public var data: Data? {
        guard case .data(let data) = self else {
            return nil
        }
        return data
    }
}
