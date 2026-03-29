import Foundation
import AppKit

enum AppPadGestureAction: String, CaseIterable, Identifiable {
    case none
    case nextPage
    case previousPage
    case closeAppPad

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none:
            return "无动作"
        case .nextPage:
            return "下一页"
        case .previousPage:
            return "上一页"
        case .closeAppPad:
            return "关闭 AppPad"
        }
    }
}

enum AppPadGestureKind: String, CaseIterable, Identifiable {
    case swipeLeft
    case swipeRight
    case swipeUp
    case swipeDown
    case magnifyIn
    case magnifyOut

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .swipeLeft:
            return "左滑"
        case .swipeRight:
            return "右滑"
        case .swipeUp:
            return "上滑"
        case .swipeDown:
            return "下滑"
        case .magnifyIn:
            return "向内捏合"
        case .magnifyOut:
            return "向外展开"
        }
    }

    var defaultsKey: String {
        "gestureAction_\(rawValue)"
    }

    var defaultAction: AppPadGestureAction {
        switch self {
        case .swipeLeft:
            return .nextPage
        case .swipeRight:
            return .previousPage
        case .swipeUp:
            return .none
        case .swipeDown:
            return .closeAppPad
        case .magnifyIn:
            return .closeAppPad
        case .magnifyOut:
            return .none
        }
    }
}

enum AppPadHotCorner: String, CaseIterable, Identifiable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .topLeft:
            return "左上角"
        case .topRight:
            return "右上角"
        case .bottomLeft:
            return "左下角"
        case .bottomRight:
            return "右下角"
        }
    }
}

enum AppPadHotCornerAction: String, CaseIterable, Identifiable {
    case toggleAppPad
    case openAppPad
    case closeAppPad

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .toggleAppPad:
            return "切换显示状态"
        case .openAppPad:
            return "打开 AppPad"
        case .closeAppPad:
            return "关闭 AppPad"
        }
    }
}

enum AppPadInputSettings {
    static let gesturesEnabledDefaultsKey = "interfaceGesturesEnabled"
    static let hotCornerEnabledDefaultsKey = "hotCornerEnabled"
    static let hotCornerPositionDefaultsKey = "hotCornerPosition"
    static let hotCornerActionDefaultsKey = "hotCornerAction"
    static let gestureActionUserInfoKey = "gestureAction"

    static func registerDefaults(_ defaults: UserDefaults = .standard) {
        var values: [String: Any] = [
            gesturesEnabledDefaultsKey: true,
            hotCornerEnabledDefaultsKey: false,
            hotCornerPositionDefaultsKey: AppPadHotCorner.bottomLeft.rawValue,
            hotCornerActionDefaultsKey: AppPadHotCornerAction.toggleAppPad.rawValue
        ]

        for kind in AppPadGestureKind.allCases {
            values[kind.defaultsKey] = kind.defaultAction.rawValue
        }

        defaults.register(defaults: values)
    }

    static func isInterfaceGesturesEnabled(_ defaults: UserDefaults = .standard) -> Bool {
        registerDefaults(defaults)
        return defaults.bool(forKey: gesturesEnabledDefaultsKey)
    }

    static func gestureAction(for kind: AppPadGestureKind, defaults: UserDefaults = .standard) -> AppPadGestureAction {
        registerDefaults(defaults)
        let rawValue = defaults.string(forKey: kind.defaultsKey) ?? kind.defaultAction.rawValue
        return AppPadGestureAction(rawValue: rawValue) ?? kind.defaultAction
    }

    static func isHotCornerEnabled(_ defaults: UserDefaults = .standard) -> Bool {
        registerDefaults(defaults)
        return defaults.bool(forKey: hotCornerEnabledDefaultsKey)
    }

    static func hotCorner(_ defaults: UserDefaults = .standard) -> AppPadHotCorner {
        registerDefaults(defaults)
        let rawValue = defaults.string(forKey: hotCornerPositionDefaultsKey) ?? AppPadHotCorner.bottomLeft.rawValue
        return AppPadHotCorner(rawValue: rawValue) ?? .bottomLeft
    }

    static func hotCornerAction(_ defaults: UserDefaults = .standard) -> AppPadHotCornerAction {
        registerDefaults(defaults)
        let rawValue = defaults.string(forKey: hotCornerActionDefaultsKey) ?? AppPadHotCornerAction.toggleAppPad.rawValue
        return AppPadHotCornerAction(rawValue: rawValue) ?? .toggleAppPad
    }
}

@MainActor
final class HotCornerManager: @unchecked Sendable {
    static let shared = HotCornerManager()

    private let activationInset: CGFloat = 3
    private let checkInterval: TimeInterval = 0.15

    private var timer: Timer?
    private var isInsideConfiguredCorner = false
    private var onTrigger: ((AppPadHotCornerAction) -> Void)?

    private init() {
        AppPadInputSettings.registerDefaults()
    }

    func configure(onTrigger: @escaping (AppPadHotCornerAction) -> Void) {
        self.onTrigger = onTrigger
        reloadConfiguration()
    }

    func reloadConfiguration() {
        AppPadInputSettings.registerDefaults()
        isInsideConfiguredCorner = false

        if AppPadInputSettings.isHotCornerEnabled() {
            startMonitoring()
        } else {
            stopMonitoring()
        }
    }

    private func startMonitoring() {
        guard timer == nil else { return }

        let timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkMouseLocation()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkMouseLocation() {
        let configuredCorner = AppPadInputSettings.hotCorner()
        let mouseLocation = NSEvent.mouseLocation
        let isInside = isPoint(mouseLocation, inside: configuredCorner)

        if isInside && !isInsideConfiguredCorner {
            isInsideConfiguredCorner = true
            onTrigger?(AppPadInputSettings.hotCornerAction())
        } else if !isInside {
            isInsideConfiguredCorner = false
        }
    }

    private func isPoint(_ point: NSPoint, inside corner: AppPadHotCorner) -> Bool {
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(point, $0.frame, false) }) else {
            return false
        }

        let frame = screen.frame

        switch corner {
        case .topLeft:
            return point.x <= frame.minX + activationInset && point.y >= frame.maxY - activationInset
        case .topRight:
            return point.x >= frame.maxX - activationInset && point.y >= frame.maxY - activationInset
        case .bottomLeft:
            return point.x <= frame.minX + activationInset && point.y <= frame.minY + activationInset
        case .bottomRight:
            return point.x >= frame.maxX - activationInset && point.y <= frame.minY + activationInset
        }
    }
}

extension Notification.Name {
    static let appPadGestureActionTriggered = Notification.Name("appPadGestureActionTriggered")
}
