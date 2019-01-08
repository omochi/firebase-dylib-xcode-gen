import Foundation

public struct Version : Hashable, Comparable, CustomStringConvertible {
    public var elements: [Int]
    
    public init(string: String) {
        self.elements = string.split(separator: ".").map { Int($0)! }
    }
    
    public var description: String {
        return elements.map { "\($0)" }.joined(separator: ".")
    }
    
    public static func <(a: Version, b: Version) -> Bool {
        var aes = a.elements[...]
        var bes = b.elements[...]
        
        while true {
            if let ah = aes.popFirst() {
                if let bh = bes.popFirst() {
                    if ah != bh {
                        return ah < bh
                    }
                } else {
                    return false
                }
            } else {
                if let _ = bes.popFirst() {                    
                    return true
                } else {
                    return false
                }
            }
        }
    }
}
