//
//  GopyApp.swift
//  Gopy
//
//  Created by Göktuğ Şahin on 6.07.2025.
//

import SwiftUI
import AppKit

@main
struct GopyApp: App {
    @StateObject private var clipboardManager = ClipboardManager()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(clipboardManager)
        } label: {
            // "G" harfi olarak ikon
            Text("G")
                .font(.system(size: 16, weight: .bold))
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var settingsWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // Create G icon
            let gIcon = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
                NSColor.labelColor.set()
                let font = NSFont.systemFont(ofSize: 16, weight: .semibold)
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: NSColor.labelColor
                ]
                let string = NSAttributedString(string: "G", attributes: attrs)
                let size = string.size()
                let drawRect = NSRect(
                    x: (rect.width - size.width) / 2,
                    y: (rect.height - size.height) / 2,
                    width: size.width,
                    height: size.height
                )
                string.draw(in: drawRect)
                return true
            }
            gIcon.isTemplate = true
            
            button.image = gIcon
            button.action = #selector(togglePopover)
            button.target = self
            
            // Add right-click menu
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Gopy'yi Göster", action: #selector(showPopover), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Ayarlar...", action: #selector(showSettings), keyEquivalent: ","))
            menu.addItem(NSMenuItem(title: "Çıkış", action: #selector(quitApp), keyEquivalent: "q"))
            
            button.menu = menu
        }
        
        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 550, height: 500)
        popover?.behavior = .transient
        popover?.animates = true
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        
        // Enable auto-launch at login
        enableAutoLaunch()
    }
    
    @objc func togglePopover() {
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                showPopover()
            }
        }
    }
    
    @objc func showPopover() {
        if let popover = popover, let button = statusItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            
            // Activate the app to ensure proper focus
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc func showSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            
            settingsWindow?.title = "Gopy Ayarları"
            settingsWindow?.contentViewController = hostingController
            settingsWindow?.center()
            settingsWindow?.setFrameAutosaveName("SettingsWindow")
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
    private func enableAutoLaunch() {
        // This would normally use SMLoginItemSetEnabled or LaunchAtLogin package
        // For now, we'll use a simple approach
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.gopy.Gopy"
        
        // Create launch agent plist if it doesn't exist
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let launchAgentsPath = homeDirectory.appendingPathComponent("Library/LaunchAgents")
        let plistPath = launchAgentsPath.appendingPathComponent("\(bundleIdentifier).plist")
        
        if !FileManager.default.fileExists(atPath: plistPath.path) {
            do {
                try FileManager.default.createDirectory(at: launchAgentsPath, withIntermediateDirectories: true)
                
                let appPath = Bundle.main.bundlePath
                let plistContent = """
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                <dict>
                    <key>Label</key>
                    <string>\(bundleIdentifier)</string>
                    <key>ProgramArguments</key>
                    <array>
                        <string>\(appPath)/Contents/MacOS/Gopy</string>
                    </array>
                    <key>RunAtLoad</key>
                    <true/>
                    <key>LSUIElement</key>
                    <true/>
                </dict>
                </plist>
                """
                
                try plistContent.write(to: plistPath, atomically: true, encoding: .utf8)
            } catch {
                print("Auto-launch kurulumu başarısız: \(error)")
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup if needed
    }
}
