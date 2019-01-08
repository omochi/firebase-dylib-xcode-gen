import Foundation

public struct PackageDef {
    public var url: URL
    public var entries: [Version: URL]
    
    public init(url: URL,
                entries: [Version: URL])
    {
        self.url = url
        self.entries = entries
    }
}
