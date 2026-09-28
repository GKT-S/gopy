import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("clipboardMonitoringInterval", store: SharedDefaults.instance) private var clipboardMonitoringInterval = 1.0
    @AppStorage("maxClipboardItems", store: SharedDefaults.instance) private var maxClipboardItems = 40
    @AppStorage("enableNotifications", store: SharedDefaults.instance) private var enableNotifications = true
    @State private var launchAtLogin: Bool = true // Default to true for first launch
    
    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        toggleLaunchAtLogin(enabled: newValue)
                    }
                
                Toggle("Show new clipboard notifications", isOn: $enableNotifications)
            }
            
            Section("Performance") {
                VStack(alignment: .leading) {
                    Text("Clipboard monitoring interval: \(clipboardMonitoringInterval, specifier: "%.1f") seconds")
                    Slider(value: $clipboardMonitoringInterval, in: 0.5...3.0, step: 0.1)
                        .help("Longer intervals use less CPU")
                }
                
                VStack(alignment: .leading) {
                    Text("Maximum saved items: \(maxClipboardItems)")
                    Slider(value: Binding(
                        get: { Double(maxClipboardItems) },
                        set: { maxClipboardItems = Int($0) }
                    ), in: 50...500, step: 10)
                        .help("Fewer items use less memory")
                }
            }
            
            Section("Shortcut") {
                HStack {
                    Text("Toggle Gopy")
                    Spacer()
                    Text("⌥ Space")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.secondary.opacity(0.15))
                        )
                }
            }

            Section("About") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gopy")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Version 1.2.0")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Smart clipboard manager")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 400)
        .navigationTitle("Settings")
        .onAppear {
            // Enable launch at login on first appearance
            if SMAppService.mainApp.status == .notRegistered {
                launchAtLogin = true
                toggleLaunchAtLogin(enabled: true)
            } else {
                launchAtLogin = SMAppService.mainApp.status == .enabled
            }
        }
    }
    
    private func toggleLaunchAtLogin(enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status == .notRegistered {
                    try SMAppService.mainApp.register()
                }
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update login item status: \(error)")
        }
    }
} 