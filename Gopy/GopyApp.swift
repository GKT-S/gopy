//
//  GopyApp.swift
//  Gopy
//
//  Created by Göktuğ Şahin on 6.07.2025.
//

import SwiftUI
import AppKit
import Carbon.HIToolbox

@main
struct GopyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var floatingPanel: FloatingPanel?
    let clipboardManager = ClipboardManager()
    private var hotKeyRef: EventHotKeyRef?
    private var clickOutsideMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusBar()
        setupFloatingPanel()
        setupCarbonHotkey()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidePanelFromNotification),
            name: .hidGopyPanel,
            object: nil
        )
    }

    @objc private func hidePanelFromNotification() {
        hidePanel()
    }

    // MARK: - Status Bar

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
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
            button.action = #selector(statusBarClicked)
            button.target = self

            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Show Gopy", action: #selector(showPanel), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())

            let shortcutItem = NSMenuItem(title: "Shortcut: ⌥ Space", action: nil, keyEquivalent: "")
            shortcutItem.isEnabled = false
            menu.addItem(shortcutItem)

            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ","))
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

            statusItem?.menu = nil

            NSEvent.addLocalMonitorForEvents(matching: .rightMouseUp) { [weak self] event in
                guard let self = self, let button = self.statusItem?.button else { return event }
                let locationInButton = button.convert(event.locationInWindow, from: nil)
                if button.bounds.contains(locationInButton) {
                    self.statusItem?.menu = menu
                    button.performClick(nil)
                    DispatchQueue.main.async {
                        self.statusItem?.menu = nil
                    }
                    return nil
                }
                return event
            }
        }
    }

    // MARK: - Carbon Global Hotkey (Option+Space) — works reliably everywhere

    private func setupCarbonHotkey() {
        let hotKeyID = EventHotKeyID(
            signature: OSType(0x474F5059), // "GOPY"
            id: 1
        )

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        // Store self in a global so the C callback can reach it
        AppDelegate.shared = self

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                DispatchQueue.main.async {
                    AppDelegate.shared?.togglePanel()
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )

        // Option + Space (keyCode 49 = Space, optionKey = Option modifier)
        RegisterEventHotKey(
            UInt32(kVK_Space),
            UInt32(optionKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    private static var shared: AppDelegate?

    // MARK: - Floating Panel

    private func setupFloatingPanel() {
        let contentView = ContentView()
            .environmentObject(clipboardManager)

        floatingPanel = FloatingPanel(content: contentView)
    }

    // MARK: - Actions

    @objc func statusBarClicked() {
        togglePanel()
    }

    func togglePanel() {
        guard let panel = floatingPanel else { return }

        if panel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    @objc func showPanel() {
        guard let panel = floatingPanel else { return }

        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let panelSize = panel.frame.size
            let x = screenFrame.midX - panelSize.width / 2
            let y = screenFrame.midY - panelSize.height / 2 + 60
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.18
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }

        // Monitor clicks outside the panel
        clickOutsideMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.hidePanel()
        }
    }

    func hidePanel() {
        guard let panel = floatingPanel, panel.isVisible else { return }

        if let monitor = clickOutsideMonitor {
            NSEvent.removeMonitor(monitor)
            clickOutsideMonitor = nil
        }

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.12
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
        })
    }

    @objc func showSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }
}

extension Notification.Name {
    static let hidGopyPanel = Notification.Name("hidGopyPanel")
}

// MARK: - Floating Panel

class FloatingPanel: NSPanel {

    init(content: some View) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 580, height: 520),
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .floating
        isMovableByWindowBackground = true
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        animationBehavior = .utilityWindow
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        isReleasedWhenClosed = false
        becomesKeyOnlyIfNeeded = false

        let hostingView = NSHostingView(rootView: content)
        self.contentView = hostingView
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            if let appDelegate = NSApp.delegate as? AppDelegate {
                appDelegate.hidePanel()
            }
        } else {
            super.keyDown(with: event)
        }
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
