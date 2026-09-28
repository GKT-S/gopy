import Foundation

enum AutoLaunchManager {
    static func ensureLaunchAgentInstalled() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        let fileManager = FileManager.default
        let homeDirectory = fileManager.homeDirectoryForCurrentUser
        let launchAgentsDirectory = homeDirectory.appendingPathComponent("Library/LaunchAgents", isDirectory: true)
        let plistURL = launchAgentsDirectory.appendingPathComponent("\(bundleIdentifier).plist")
        
        do {
            if !fileManager.fileExists(atPath: launchAgentsDirectory.path) {
                try fileManager.createDirectory(at: launchAgentsDirectory, withIntermediateDirectories: true)
            }
            
            let appExecutable = Bundle.main.bundlePath.appending("/Contents/MacOS/Gopy")
            let expectedPlist = launchAgentPlist(bundleIdentifier: bundleIdentifier, executablePath: appExecutable)
            
            if !fileManager.fileExists(atPath: plistURL.path) {
                try expectedPlist.write(to: plistURL, atomically: true, encoding: .utf8)
            } else {
                let currentPlist = try String(contentsOf: plistURL, encoding: .utf8)
                if currentPlist != expectedPlist {
                    try expectedPlist.write(to: plistURL, atomically: true, encoding: .utf8)
                }
            }
        } catch {
            NSLog("[Gopy] Failed to configure launch agent: \(error.localizedDescription)")
        }
    }
    
    private static func launchAgentPlist(bundleIdentifier: String, executablePath: String) -> String {
        """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
        <plist version=\"1.0\">
        <dict>
            <key>Label</key>
            <string>\(bundleIdentifier)</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(executablePath)</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <true/>
        </dict>
        </plist>
        """
    }
}
