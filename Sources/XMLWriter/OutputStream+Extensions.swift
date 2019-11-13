import Foundation

extension OutputStream {
    internal var inMemoryData: Data? {
        return self.property(forKey: .dataWrittenToMemoryStreamKey) as! Data?
    }
    
    internal var inMemoryString: String? {
        return self.inMemoryData.flatMap { data in
            String(data: data, encoding: .utf8)
        }
    }
}
