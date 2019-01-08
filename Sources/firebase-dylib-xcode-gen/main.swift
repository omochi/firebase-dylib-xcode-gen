import Foundation

private let fm = FileManager.default

public class App {
    public let rootURL: URL
    public let cacheDir: URL
    public let frameworkDir: URL
    public var packageDefs: [PackageDef] = []
    
    public static func main() throws {
        _ = try App()
    }
    
    public init() throws {
        self.rootURL = URL(string: "https://raw.githubusercontent.com/firebase/firebase-ios-sdk/master/Carthage.md")!
        self.cacheDir = URL(fileURLWithPath: "cache")
        self.frameworkDir = URL(fileURLWithPath: "framework")

        try fm.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        
        try fm.createDirectory(at: frameworkDir, withIntermediateDirectories: true)
        
        print("cacheDir: \(cacheDir.path)")
        
        let text = try curlCapture(url: rootURL).decodeUTF8()
        
        let regex = Regex(pattern: "binary \"(.*)\"", options: [])
        let urls: [URL] = regex.matches(string: text).map { URL(string: $0[1]!)! }
        
        for url in urls {
            try process(packageURL: url)
        }
        
        var versions = Set<Version>()
        for def in packageDefs {
            for ver in def.entries.keys {
                versions.insert(ver)
            }
        }
        let latestVersion = versions.max()!
        print("latest version: \(latestVersion)")
        
        var extDirs: [URL] = []
        for def in packageDefs {
            let url = def.entries[latestVersion]!
            
            let zipPath = try curlDownload(url: url)
            let extDir = try unzip(path: zipPath)
            extDirs.append(extDir)
        }
        
        for dir in extDirs {
            let items = try fm.contentsOfDirectory(atPath: dir.path)
            for item in items {
                if (item as NSString).pathExtension == "framework" {
                    let src = dir.appendingPathComponent(item)
                    let dest = frameworkDir.appendingPathComponent(item)
                    if !fm.fileExists(atPath: dest.path) {
                        try fm.copyItem(at: src, to: dest)
                    }
                }
            }
        }
    }

    private func process(packageURL: URL) throws {
        let jsonData = try curlCapture(url: packageURL)
        
        let decoder = JSONDecoder()
        let strEntries = try decoder.decode([String: String].self, from: jsonData)
        
        let entries = Dictionary(uniqueKeysWithValues:
            strEntries.map { (ver, url) in
                (Version(string: ver), URL(string: url)!)
        })
        
        let def = PackageDef(url: packageURL, entries: entries)
        self.packageDefs.append(def)
    }
    
    private func curlCapture(url: URL) throws -> Data {
        let path = try curlDownload(url: url)
        return try Data(contentsOf: path)
    }
    
    private func curlDownload(url: URL) throws -> URL
    {
        let cachePath = cacheDir.appendingPathComponent(url.lastPathComponent)
        
        if fm.fileExists(atPath: cachePath.path) {
            return cachePath
        }
        
        print("download \(url.absoluteString)")
        
        let proc = try Process(command: "curl",
                               args: ["-o", cachePath.path, url.absoluteString])
        proc.launch()
        proc.waitUntilExit()
        
        return cachePath
    }
    
    private func unzip(path zipPath: URL) throws -> URL {
        let name = zipPath.lastPathComponent
        let dir = zipPath.deletingLastPathComponent()
        let extPath = dir.appendingPathComponent((name as NSString).deletingPathExtension)
        
        if fm.fileExists(atPath: extPath.path) {
            return extPath
        }
        
        print("unzip \(extPath.path)")
        
        let proc = try Process(command: "unzip",
                               args: [zipPath.path, "-d", extPath.path])
        proc.launch()
        proc.waitUntilExit()
        
        return extPath
    }
}

try App.main()

