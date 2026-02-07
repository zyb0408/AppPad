import SwiftUI

struct SettingsView: View {
    @AppStorage("iconSize") private var iconSize: Double = 80.0
    @AppStorage("gridColumns") private var gridColumns: Int = 7
    @AppStorage("gridRows") private var gridRows: Int = 5
    @AppStorage("gestureSensitivity") private var gestureSensitivity: Double = 0.5
    @AppStorage("backgroundColorHex") private var backgroundColorHex: String = "#9a6262ff"
    @AppStorage("backgroundOpacity") private var backgroundOpacity: Double = 0.85
    @AppStorage("animationSpeed") private var animationSpeed: Double = 0.3
    @AppStorage("globalShortcutEnabled") private var globalShortcutEnabled: Bool = true
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    
    @State private var selectedColor: Color = Color(hex: "#a94040ff")
    
    private let labelWidth: CGFloat = 100
    
    var body: some View {
        TabView {
            // MARK: - 外观标签页
            appearanceTab
                .tabItem {
                    Label("外观", systemImage: "paintbrush")
                }
            
            // MARK: - 行为标签页
            behaviorTab
                .tabItem {
                    Label("行为", systemImage: "hand.tap")
                }
            
            // MARK: - 通用标签页
            generalTab
                .tabItem {
                    Label("通用", systemImage: "gear")
                }
        }
        .frame(width: 480, height: 380)
        .onAppear {
            selectedColor = Color(hex: backgroundColorHex)
        }
    }
    
    // MARK: - 外观标签页
    private var appearanceTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 图标显示
                SettingsSectionView(title: "图标显示") {
                    SettingsRowView(label: "图标大小", labelWidth: labelWidth) {
                        HStack(spacing: 12) {
                            Slider(value: $iconSize, in: 40...120, step: 4)
                            Text("\(Int(iconSize)) px")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 50, alignment: .trailing)
                        }
                    }
                }
                
                // 网格布局
                SettingsSectionView(title: "网格布局") {
                    VStack(spacing: 12) {
                        SettingsRowView(label: "列数", labelWidth: labelWidth) {
                            HStack {
                                Stepper("\(gridColumns)", value: $gridColumns, in: 4...12)
                                    .labelsHidden()
                                Text("\(gridColumns)")
                                    .font(.system(.body, design: .monospaced))
                                    .frame(width: 30, alignment: .center)
                            }
                            Spacer()
                        }
                        
                        SettingsRowView(label: "行数", labelWidth: labelWidth) {
                            HStack {
                                Stepper("\(gridRows)", value: $gridRows, in: 3...10)
                                    .labelsHidden()
                                Text("\(gridRows)")
                                    .font(.system(.body, design: .monospaced))
                                    .frame(width: 30, alignment: .center)
                            }
                            Spacer()
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        HStack {
                            Text("每页应用数")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(gridColumns * gridRows) 个")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 视觉效果
                SettingsSectionView(title: "视觉效果") {
                    VStack(spacing: 12) {
                        SettingsRowView(label: "背景颜色", labelWidth: labelWidth) {
                            ColorPicker("", selection: $selectedColor, supportsOpacity: true)
                                .labelsHidden()
                                .onChange(of: selectedColor) { _, newColor in
                                    backgroundColorHex = newColor.toHex()
                                }
                            Spacer()
                        }
                        
                        SettingsRowView(label: "背景透明度", labelWidth: labelWidth) {
                            HStack(spacing: 12) {
                                Slider(value: $backgroundOpacity, in: 0.0...1.0, step: 0.05)
                                Text("\(Int(backgroundOpacity * 100))%")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(width: 50, alignment: .trailing)
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
    }
    
    // MARK: - 行为标签页
    private var behaviorTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 手势
                SettingsSectionView(title: "手势") {
                    VStack(alignment: .leading, spacing: 8) {
                        SettingsRowView(label: "滑动冷却", labelWidth: labelWidth) {
                            HStack(spacing: 12) {
                                Slider(value: $gestureSensitivity, in: 0.1...1.5, step: 0.1)
                                Text("\(String(format: "%.1f", gestureSensitivity)) 秒")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .trailing)
                            }
                        }
                        Text("翻页之间的最小时间间隔")
                            .font(.caption)
                            .foregroundColor(Color(nsColor: .tertiaryLabelColor))
                            .padding(.leading, labelWidth + 8)
                    }
                }
                
                // 动画
                SettingsSectionView(title: "动画") {
                    VStack(alignment: .leading, spacing: 8) {
                        SettingsRowView(label: "动画速度", labelWidth: labelWidth) {
                            HStack(spacing: 12) {
                                Slider(value: $animationSpeed, in: 0.1...1.0, step: 0.1)
                                Text("\(String(format: "%.1f", animationSpeed)) 秒")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .trailing)
                            }
                        }
                        Text("打开/关闭动画的持续时间")
                            .font(.caption)
                            .foregroundColor(Color(nsColor: .tertiaryLabelColor))
                            .padding(.leading, labelWidth + 8)
                    }
                }
                
                // 快捷键
                SettingsSectionView(title: "快捷键") {
                    VStack(spacing: 12) {
                        SettingsRowView(label: "全局快捷键", labelWidth: labelWidth) {
                            Toggle("", isOn: $globalShortcutEnabled)
                                .labelsHidden()
                                .toggleStyle(.switch)
                            Spacer()
                        }
                        
                        SettingsRowView(label: "热键", labelWidth: labelWidth) {
                            HStack(spacing: 4) {
                                KeyCapView(key: "⌥")
                                Text("+")
                                    .foregroundColor(.secondary)
                                KeyCapView(key: "Space")
                            }
                            Spacer()
                        }
                    }
                }
            }
            .padding(24)
        }
    }
    
    // MARK: - 通用标签页
    private var generalTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 启动
                SettingsSectionView(title: "启动") {
                    SettingsRowView(label: "登录时启动", labelWidth: labelWidth) {
                        Toggle("", isOn: $launchAtLogin)
                            .labelsHidden()
                            .toggleStyle(.switch)
                        Spacer()
                    }
                }
                
                // 关于
                SettingsSectionView(title: "关于") {
                    VStack(spacing: 12) {
                        SettingsRowView(label: "版本", labelWidth: labelWidth) {
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        SettingsRowView(label: "构建日期", labelWidth: labelWidth) {
                            Text("2026.02.04")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        Text("AppPad 是一个具有增强自定义功能的 macOS Launchpad 替代品。")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // 重置
                SettingsSectionView(title: "重置") {
                    Button(action: resetToDefaults) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("恢复默认设置")
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(24)
        }
    }
    
    private func resetToDefaults() {
        iconSize = 80.0
        gridColumns = 7
        gridRows = 5
        gestureSensitivity = 0.5
        backgroundColorHex = "#8e5252ff"
        selectedColor = Color(hex: "#8e5252ff")
        backgroundOpacity = 0.85
        animationSpeed = 0.3
        globalShortcutEnabled = true
        launchAtLogin = false
    }
}

// MARK: - 设置区域视图
struct SettingsSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - 设置行视图
struct SettingsRowView<Content: View>: View {
    let label: String
    let labelWidth: CGFloat
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(label)
                .frame(width: labelWidth, alignment: .trailing)
            
            content
        }
    }
}

// MARK: - 按键帽视图
struct KeyCapView: View {
    let key: String
    
    var body: some View {
        Text(key)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    SettingsView()
}
