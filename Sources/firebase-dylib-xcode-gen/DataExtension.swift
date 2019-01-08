import Foundation

extension Data {
    public enum ExtensionError : Swift.Error {
        case invalidUTF8
    }
    
    public func decodeUTF8() throws -> String {
        guard let str = String(data: self, encoding: .utf8) else {
            throw ExtensionError.invalidUTF8
        }
        
        return str
    }
}
