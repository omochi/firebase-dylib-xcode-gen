import Foundation

extension Process {
    public convenience init(command: String,
                            args: [String]) throws
    {
        let path = try Process.find(command: command).path
        
        self.init()
        self.launchPath = path
        self.arguments = args
    }
    
    public static func find(command: String) throws -> URL {
        let proc = Process()
        proc.launchPath = "/usr/bin/which"
        proc.arguments = [command]
        let outData = try proc.capture()
        var out = try outData.decodeUTF8()
        out = out.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return URL(fileURLWithPath: out)
    }
    
    public func capture() throws -> Data {
        let outPipe = Pipe()
        self.standardOutput = outPipe
        
        var out = Data()
        
        outPipe.fileHandleForReading.readabilityHandler = { (handle) in
            let chunk = handle.readDataToEndOfFile()
            out.append(chunk)
        }
        
        self.standardError = FileHandle.standardError

        self.launch()
        
        self.waitUntilExit()
        
        return out
    }
}
