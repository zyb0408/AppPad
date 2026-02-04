import SwiftUI

struct SettingsView: View {
    @AppStorage("iconSize") private var iconSize: Double = 80.0
    @AppStorage("gridColumns") private var gridColumns: Int = 7
    @AppStorage("gridRows") private var gridRows: Int = 5
    @AppStorage("gestureSensitivity") private var gestureSensitivity: Double = 0.5
    @AppStorage("backgroundBlurIntensity") private var backgroundBlurIntensity: Double = 1.0
    @AppStorage("animationSpeed") private var animationSpeed: Double = 0.3
    @AppStorage("globalShortcutEnabled") private var globalShortcutEnabled: Bool = true
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    
    var body: some View {
        TabView {
            // Appearance Tab
            Form {
                Section(header: Text("Icon Display")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Icon Size")
                            Spacer()
                            Text("\(Int(iconSize))px")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $iconSize, in: 40...120, step: 4)
                    }
                }
                
                Section(header: Text("Grid Layout")) {
                    Stepper("Columns: \(gridColumns)", value: $gridColumns, in: 4...12)
                    Stepper("Rows: \(gridRows)", value: $gridRows, in: 3...10)
                    
                    Text("Apps per page: \(gridColumns * gridRows)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Visual Effects")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Background Blur")
                            Spacer()
                            Text("\(Int(backgroundBlurIntensity * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $backgroundBlurIntensity, in: 0.0...1.0, step: 0.1)
                    }
                }
            }
            .padding()
            .tabItem {
                Label("Appearance", systemImage: "paintbrush")
            }
            
            // Behavior Tab
            Form {
                Section(header: Text("Gestures")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Swipe Cooldown")
                            Spacer()
                            Text("\(String(format: "%.1f", gestureSensitivity))s")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $gestureSensitivity, in: 0.1...1.5, step: 0.1)
                    }
                    
                    Text("Minimum time between page flips")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Animations")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Animation Speed")
                            Spacer()
                            Text("\(String(format: "%.1f", animationSpeed))s")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $animationSpeed, in: 0.1...1.0, step: 0.1)
                    }
                    
                    Text("Duration for open/close animations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Shortcuts")) {
                    Toggle("Enable Global Shortcut", isOn: $globalShortcutEnabled)
                    
                    HStack {
                        Text("Hotkey")
                        Spacer()
                        Text("⌥ Space")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Press Option + Space to toggle AppPad")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .tabItem {
                Label("Behavior", systemImage: "hand.tap")
            }
            
            // General Tab
            Form {
                Section(header: Text("Startup")) {
                    Toggle("Launch at Login", isOn: $launchAtLogin)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2026.02.04")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("A macOS Launchpad alternative with enhanced customization.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                Section {
                    Button("Reset to Defaults") {
                        resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .padding()
            .tabItem {
                Label("General", systemImage: "gear")
            }
        }
        .frame(width: 500, height: 400)
    }
    
    private func resetToDefaults() {
        iconSize = 80.0
        gridColumns = 7
        gridRows = 5
        gestureSensitivity = 0.5
        backgroundBlurIntensity = 1.0
        animationSpeed = 0.3
        globalShortcutEnabled = true
        launchAtLogin = false
    }
}

#Preview {
    SettingsView()
}
