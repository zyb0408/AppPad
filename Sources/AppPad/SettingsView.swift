import SwiftUI
import Carbon

struct SettingsView: View {
    @AppStorage("iconSize") private var iconSize: Double = 80.0
    @AppStorage("gridColumns") private var gridColumns: Int = 7
    @AppStorage("gridRows") private var gridRows: Int = 5
    @AppStorage("gestureSensitivity") private var gestureSensitivity: Double = 0.5
    @AppStorage("backgroundColorHex") private var backgroundColorHex: String = "#9a6262ff"
    @AppStorage("backgroundOpacity") private var backgroundOpacity: Double = 0.85
    @AppStorage("animationSpeed") private var animationSpeed: Double = 0.2
    @AppStorage("globalShortcutEnabled") private var globalShortcutEnabled: Bool = true
    @AppStorage(AppHotkey.keyCodeDefaultsKey) private var globalShortcutKeyCode: Int = Int(AppHotkey.default.keyCode)
    @AppStorage(AppHotkey.modifiersDefaultsKey) private var globalShortcutModifiers: Int = Int(AppHotkey.default.modifiers)
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @AppStorage(AppPadInputSettings.gesturesEnabledDefaultsKey) private var interfaceGesturesEnabled: Bool = true
    @AppStorage(AppPadInputSettings.hotCornerEnabledDefaultsKey) private var hotCornerEnabled: Bool = false
    @AppStorage(AppPadInputSettings.hotCornerPositionDefaultsKey) private var hotCornerPositionRaw: String = AppPadHotCorner.bottomLeft.rawValue
    @AppStorage(AppPadInputSettings.hotCornerActionDefaultsKey) private var hotCornerActionRaw: String = AppPadHotCornerAction.toggleAppPad.rawValue
    @AppStorage("gestureAction_swipeLeft") private var swipeLeftActionRaw: String = AppPadGestureKind.swipeLeft.defaultAction.rawValue
    @AppStorage("gestureAction_swipeRight") private var swipeRightActionRaw: String = AppPadGestureKind.swipeRight.defaultAction.rawValue
    @AppStorage("gestureAction_swipeUp") private var swipeUpActionRaw: String = AppPadGestureKind.swipeUp.defaultAction.rawValue
    @AppStorage("gestureAction_swipeDown") private var swipeDownActionRaw: String = AppPadGestureKind.swipeDown.defaultAction.rawValue
    @AppStorage("gestureAction_magnifyIn") private var magnifyInActionRaw: String = AppPadGestureKind.magnifyIn.defaultAction.rawValue
    @AppStorage("gestureAction_magnifyOut") private var magnifyOutActionRaw: String = AppPadGestureKind.magnifyOut.defaultAction.rawValue
    
    @State private var selectedColor: Color = Color(hex: "#a94040ff")
    @State private var launchAtLoginError: String?
    @State private var hotkeyHint: String?
    @State private var didSyncLaunchAtLoginState = false
    
    private let labelWidth: CGFloat = 100

    private var shortcutBinding: Binding<AppHotkey> {
        Binding(
            get: {
                AppHotkey(
                    keyCode: UInt32(globalShortcutKeyCode),
                    modifiers: UInt32(globalShortcutModifiers)
                )
            },
            set: { newValue in
                globalShortcutKeyCode = Int(newValue.keyCode)
                globalShortcutModifiers = Int(newValue.modifiers)
            }
        )
    }
    
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
            launchAtLogin = LaunchAtLoginManager.shared.isEnabled
            didSyncLaunchAtLoginState = true
        }
        .onChange(of: globalShortcutEnabled) { _, newValue in
            hotkeyHint = newValue ? nil : "已关闭全局快捷键"
            GlobalHotkeyManager.shared.reloadRegistration()
        }
        .onChange(of: launchAtLogin) { _, newValue in
            guard didSyncLaunchAtLoginState else { return }
            updateLaunchAtLogin(newValue)
        }
        .onChange(of: hotCornerEnabled) { _, _ in
            HotCornerManager.shared.reloadConfiguration()
        }
        .onChange(of: hotCornerPositionRaw) { _, _ in
            HotCornerManager.shared.reloadConfiguration()
        }
        .onChange(of: hotCornerActionRaw) { _, _ in
            HotCornerManager.shared.reloadConfiguration()
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
                SettingsSectionView(title: "界面手势") {
                    VStack(alignment: .leading, spacing: 12) {
                        SettingsRowView(label: "启用手势", labelWidth: labelWidth) {
                            Toggle("", isOn: $interfaceGesturesEnabled)
                                .labelsHidden()
                                .toggleStyle(.switch)
                            Spacer()
                        }

                        SettingsRowView(label: "手势冷却", labelWidth: labelWidth) {
                            HStack(spacing: 12) {
                                Slider(value: $gestureSensitivity, in: 0.1...1.5, step: 0.1)
                                Text("\(String(format: "%.1f", gestureSensitivity)) 秒")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .trailing)
                            }
                        }
                        ForEach(AppPadGestureKind.allCases) { gesture in
                            SettingsRowView(label: gesture.displayName, labelWidth: labelWidth) {
                                Picker("", selection: gestureBinding(for: gesture)) {
                                    ForEach(AppPadGestureAction.allCases) { action in
                                        Text(action.displayName).tag(action)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 180, alignment: .leading)
                                .disabled(!interfaceGesturesEnabled)
                                Spacer()
                            }
                        }

                        Text("仅在 AppPad 已打开且处于前台时生效。默认左滑上一页、右滑下一页、下滑关闭，其余手势默认无动作。")
                            .font(.caption)
                            .foregroundColor(Color(nsColor: .tertiaryLabelColor))
                            .padding(.leading, labelWidth + 8)
                    }
                }

                SettingsSectionView(title: "热角") {
                    VStack(alignment: .leading, spacing: 12) {
                        SettingsRowView(label: "启用热角", labelWidth: labelWidth) {
                            Toggle("", isOn: $hotCornerEnabled)
                                .labelsHidden()
                                .toggleStyle(.switch)
                            Spacer()
                        }

                        SettingsRowView(label: "角落位置", labelWidth: labelWidth) {
                            Picker("", selection: hotCornerBinding) {
                                ForEach(AppPadHotCorner.allCases) { corner in
                                    Text(corner.displayName).tag(corner)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 180, alignment: .leading)
                            .disabled(!hotCornerEnabled)
                            Spacer()
                        }

                        SettingsRowView(label: "触发动作", labelWidth: labelWidth) {
                            Picker("", selection: hotCornerActionBinding) {
                                ForEach(AppPadHotCornerAction.allCases) { action in
                                    Text(action.displayName).tag(action)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 180, alignment: .leading)
                            .disabled(!hotCornerEnabled)
                            Spacer()
                        }

                        Text("热角在 AppPad 后台常驻时也能触发。如果和你平时的角落操作习惯冲突，可以随时关闭。")
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
                            HotkeyRecorderView(hotkey: shortcutBinding, isEnabled: globalShortcutEnabled) { newHotkey in
                                shortcutBinding.wrappedValue = newHotkey
                                hotkeyHint = "新的快捷键已生效"
                                GlobalHotkeyManager.shared.reloadRegistration()
                            }
                            .frame(width: 180, height: 32)
                            Spacer()
                        }

                        Text(globalShortcutEnabled ? (hotkeyHint ?? "点击后按下新的组合键，必须包含修饰键") : "启用后才会注册系统级快捷键")
                            .font(.caption)
                            .foregroundColor(Color(nsColor: .tertiaryLabelColor))
                            .padding(.leading, labelWidth + 8)
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
                    VStack(alignment: .leading, spacing: 8) {
                        SettingsRowView(label: "登录时启动", labelWidth: labelWidth) {
                            Toggle("", isOn: $launchAtLogin)
                                .labelsHidden()
                                .toggleStyle(.switch)
                            Spacer()
                        }

                        Text(launchAtLoginError ?? "启用后会通过系统登录项自动启动 AppPad")
                            .font(.caption)
                            .foregroundColor(launchAtLoginError == nil ? Color(nsColor: .tertiaryLabelColor) : .red)
                            .padding(.leading, labelWidth + 8)
                    }
                }
                
                // 关于
                SettingsSectionView(title: "关于") {
                    VStack(spacing: 12) {
                        SettingsRowView(label: "版本", labelWidth: labelWidth) {
                            Text("1.0.3")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        SettingsRowView(label: "构建日期", labelWidth: labelWidth) {
                            Text("2026.03.29")
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
        interfaceGesturesEnabled = true
        hotCornerEnabled = false
        hotCornerPositionRaw = AppPadHotCorner.bottomLeft.rawValue
        hotCornerActionRaw = AppPadHotCornerAction.toggleAppPad.rawValue
        swipeLeftActionRaw = AppPadGestureKind.swipeLeft.defaultAction.rawValue
        swipeRightActionRaw = AppPadGestureKind.swipeRight.defaultAction.rawValue
        swipeUpActionRaw = AppPadGestureKind.swipeUp.defaultAction.rawValue
        swipeDownActionRaw = AppPadGestureKind.swipeDown.defaultAction.rawValue
        magnifyInActionRaw = AppPadGestureKind.magnifyIn.defaultAction.rawValue
        magnifyOutActionRaw = AppPadGestureKind.magnifyOut.defaultAction.rawValue
        backgroundColorHex = "#8e5252ff"
        selectedColor = Color(hex: "#8e5252ff")
        backgroundOpacity = 0.85
        animationSpeed = 0.2
        globalShortcutEnabled = true
        launchAtLogin = false
        shortcutBinding.wrappedValue = .default
        hotkeyHint = "已恢复为默认快捷键"
        GlobalHotkeyManager.shared.reloadRegistration()
        HotCornerManager.shared.reloadConfiguration()
        updateLaunchAtLogin(false)
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            try LaunchAtLoginManager.shared.setEnabled(enabled)
            launchAtLoginError = nil
        } catch {
            launchAtLoginError = "登录项更新失败：\(error.localizedDescription)"
            launchAtLogin = LaunchAtLoginManager.shared.isEnabled
        }
    }

    private var hotCornerBinding: Binding<AppPadHotCorner> {
        Binding(
            get: { AppPadHotCorner(rawValue: hotCornerPositionRaw) ?? .bottomLeft },
            set: { hotCornerPositionRaw = $0.rawValue }
        )
    }

    private var hotCornerActionBinding: Binding<AppPadHotCornerAction> {
        Binding(
            get: { AppPadHotCornerAction(rawValue: hotCornerActionRaw) ?? .toggleAppPad },
            set: { hotCornerActionRaw = $0.rawValue }
        )
    }

    private func gestureBinding(for kind: AppPadGestureKind) -> Binding<AppPadGestureAction> {
        Binding(
            get: {
                AppPadGestureAction(rawValue: gestureActionRawValue(for: kind)) ?? kind.defaultAction
            },
            set: { newValue in
                setGestureActionRawValue(newValue.rawValue, for: kind)
            }
        )
    }

    private func gestureActionRawValue(for kind: AppPadGestureKind) -> String {
        switch kind {
        case .swipeLeft:
            return swipeLeftActionRaw
        case .swipeRight:
            return swipeRightActionRaw
        case .swipeUp:
            return swipeUpActionRaw
        case .swipeDown:
            return swipeDownActionRaw
        case .magnifyIn:
            return magnifyInActionRaw
        case .magnifyOut:
            return magnifyOutActionRaw
        }
    }

    private func setGestureActionRawValue(_ value: String, for kind: AppPadGestureKind) {
        switch kind {
        case .swipeLeft:
            swipeLeftActionRaw = value
        case .swipeRight:
            swipeRightActionRaw = value
        case .swipeUp:
            swipeUpActionRaw = value
        case .swipeDown:
            swipeDownActionRaw = value
        case .magnifyIn:
            magnifyInActionRaw = value
        case .magnifyOut:
            magnifyOutActionRaw = value
        }
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
