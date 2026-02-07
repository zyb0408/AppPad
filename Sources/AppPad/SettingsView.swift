import SwiftUI

struct SettingsView: View {
    @AppStorage("iconSize") private var iconSize: Double = 80.0
    @AppStorage("gridColumns") private var gridColumns: Int = 7
    @AppStorage("gridRows") private var gridRows: Int = 5
    @AppStorage("gestureSensitivity") private var gestureSensitivity: Double = 0.5
    @AppStorage("backgroundColorHex") private var backgroundColorHex: String = "#1E1E1E"
    @AppStorage("backgroundOpacity") private var backgroundOpacity: Double = 0.85
    @AppStorage("animationSpeed") private var animationSpeed: Double = 0.3
    @AppStorage("globalShortcutEnabled") private var globalShortcutEnabled: Bool = true
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    
    @State private var selectedColor: Color = Color(hex: "#1E1E1E")
    
    var body: some View {
        TabView {
            // 外观标签页
            Form {
                Section(header: Text("图标显示")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("图标大小")
                            Spacer()
                            Text("\(Int(iconSize))px")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $iconSize, in: 40...120, step: 4)
                    }
                }
                
                Section(header: Text("网格布局")) {
                    Stepper("列数：\(gridColumns)", value: $gridColumns, in: 4...12)
                    Stepper("行数：\(gridRows)", value: $gridRows, in: 3...10)
                    
                    Text("每页应用数：\(gridColumns * gridRows)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("视觉效果")) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Background color picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("背景颜色")
                            ColorPicker("", selection: $selectedColor, supportsOpacity: true)
                                .labelsHidden()
                                .onChange(of: selectedColor) { _, newColor in
                                    backgroundColorHex = newColor.toHex()
                                }
                        }
                        
                        Divider()
                        
                        // Background opacity slider
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("背景透明度")
                                Spacer()
                                Text("\(Int(backgroundOpacity * 100))%")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $backgroundOpacity, in: 0.0...1.0, step: 0.05)
                        }
                    }
                }
            }
            .padding()
            .tabItem {
                Label("外观", systemImage: "paintbrush")
            }
            
            // 行为标签页
            Form {
                Section(header: Text("手势")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("滑动冷却时间")
                            Spacer()
                            Text("\(String(format: "%.1f", gestureSensitivity))秒")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $gestureSensitivity, in: 0.1...1.5, step: 0.1)
                    }
                    
                    Text("翻页之间的最小时间间隔")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("动画")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("动画速度")
                            Spacer()
                            Text("\(String(format: "%.1f", animationSpeed))秒")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $animationSpeed, in: 0.1...1.0, step: 0.1)
                    }
                    
                    Text("打开/关闭动画的持续时间")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("快捷键")) {
                    Toggle("启用全局快捷键", isOn: $globalShortcutEnabled)
                    
                    HStack {
                        Text("热键")
                        Spacer()
                        Text("⌥ 空格")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("按 Option + 空格 切换 AppPad")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .tabItem {
                Label("行为", systemImage: "hand.tap")
            }
            
            // 通用标签页
            Form {
                Section(header: Text("启动")) {
                    Toggle("登录时启动", isOn: $launchAtLogin)
                }
                
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("构建")
                        Spacer()
                        Text("2026.02.04")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("一个具有增强自定义功能的 macOS Launchpad 替代品。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                Section {
                    Button("恢复默认设置") {
                        resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .padding()
            .tabItem {
                Label("通用", systemImage: "gear")
            }
        }
        .frame(width: 500, height: 400)
        .onAppear {
            // Initialize color from stored hex value
            selectedColor = Color(hex: backgroundColorHex)
        }
    }
    
    private func resetToDefaults() {
        iconSize = 80.0
        gridColumns = 7
        gridRows = 5
        gestureSensitivity = 0.5
        backgroundColorHex = "#1E1E1E"
        selectedColor = Color(hex: "#1E1E1E")
        backgroundOpacity = 0.85
        animationSpeed = 0.3
        globalShortcutEnabled = true
        launchAtLogin = false
    }
}

#Preview {
    SettingsView()
}
