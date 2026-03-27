import Foundation
import AppKit
import Carbon

struct AppHotkey: Equatable {
    static let keyCodeDefaultsKey = "globalShortcutKeyCode"
    static let modifiersDefaultsKey = "globalShortcutModifiers"
    static let enabledDefaultsKey = "globalShortcutEnabled"

    static let `default` = AppHotkey(keyCode: KeyCode.space.rawValue, modifiers: UInt32(optionKey))

    let keyCode: UInt32
    let modifiers: UInt32

    var isValid: Bool {
        modifiers != 0 && !Self.modifierOnlyKeyCodes.contains(keyCode)
    }

    var displayParts: [String] {
        modifierSymbols + [Self.displayString(for: keyCode)]
    }

    private var modifierSymbols: [String] {
        var result: [String] = []
        if modifiers & UInt32(controlKey) != 0 { result.append("⌃") }
        if modifiers & UInt32(optionKey) != 0 { result.append("⌥") }
        if modifiers & UInt32(shiftKey) != 0 { result.append("⇧") }
        if modifiers & UInt32(cmdKey) != 0 { result.append("⌘") }
        return result
    }

    static func load(from defaults: UserDefaults = .standard) -> AppHotkey {
        defaults.register(defaults: [
            enabledDefaultsKey: true,
            keyCodeDefaultsKey: Int(Self.default.keyCode),
            modifiersDefaultsKey: Int(Self.default.modifiers)
        ])

        return AppHotkey(
            keyCode: UInt32(defaults.integer(forKey: keyCodeDefaultsKey)),
            modifiers: UInt32(defaults.integer(forKey: modifiersDefaultsKey))
        )
    }

    static func save(_ hotkey: AppHotkey, to defaults: UserDefaults = .standard) {
        defaults.set(Int(hotkey.keyCode), forKey: keyCodeDefaultsKey)
        defaults.set(Int(hotkey.modifiers), forKey: modifiersDefaultsKey)
    }

    static func from(event: NSEvent) -> AppHotkey? {
        let modifiers = carbonModifiers(from: event.modifierFlags)
        let hotkey = AppHotkey(keyCode: UInt32(event.keyCode), modifiers: modifiers)
        return hotkey.isValid ? hotkey : nil
    }

    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        let relevantFlags = flags.intersection([.command, .option, .control, .shift])
        var result: UInt32 = 0

        if relevantFlags.contains(.command) { result |= UInt32(cmdKey) }
        if relevantFlags.contains(.option) { result |= UInt32(optionKey) }
        if relevantFlags.contains(.control) { result |= UInt32(controlKey) }
        if relevantFlags.contains(.shift) { result |= UInt32(shiftKey) }

        return result
    }

    static func displayString(for keyCode: UInt32) -> String {
        keyDisplayMap[keyCode] ?? "Key \(keyCode)"
    }

    private static let modifierOnlyKeyCodes: Set<UInt32> = [
        54, 55, 56, 57, 58, 59, 60, 61, 62
    ]

    private static let keyDisplayMap: [UInt32: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
        8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
        16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
        23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
        30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L",
        38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/",
        45: "N", 46: "M", 47: ".", 49: "Space", 50: "`", 36: "Return",
        48: "Tab", 51: "Delete", 53: "Esc", 123: "←", 124: "→",
        125: "↓", 126: "↑"
    ]
}

/// Global hotkey manager for AppPad
@MainActor
final class GlobalHotkeyManager: @unchecked Sendable {
    static let shared = GlobalHotkeyManager()
    
    private var eventHotKey: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var onActivate: (() -> Void)?
    
    private init() {
        _ = AppHotkey.load()
    }

    func configure(onActivate: @escaping () -> Void) {
        self.onActivate = onActivate
        reloadRegistration()
    }
    
    /// Register a global hotkey
    /// - Parameters:
    ///   - keyCode: Virtual key code (e.g., 49 for Space)
    ///   - modifiers: Modifier flags (e.g., optionKey)
    ///   - onActivate: Callback when hotkey is pressed
    func registerHotkey(keyCode: UInt32, modifiers: UInt32, onActivate: @escaping () -> Void) {
        self.onActivate = onActivate
        
        // Unregister existing hotkey
        unregisterHotkey()
        
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType("APPD".fourCharCodeValue)
        hotKeyID.id = 1
        
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)
        
        // Install event handler
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                Task { @MainActor in
                    GlobalHotkeyManager.shared.onActivate?()
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )
        
        // Register hotkey
        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &eventHotKey
        )
    }

    func reloadRegistration() {
        unregisterHotkey()

        guard UserDefaults.standard.object(forKey: AppHotkey.enabledDefaultsKey) as? Bool ?? true else {
            return
        }

        guard let onActivate, AppHotkey.load().isValid else {
            return
        }

        let hotkey = AppHotkey.load()
        registerHotkey(keyCode: hotkey.keyCode, modifiers: hotkey.modifiers, onActivate: onActivate)
    }
    
    /// Unregister the current hotkey
    func unregisterHotkey() {
        if let eventHotKey = eventHotKey {
            UnregisterEventHotKey(eventHotKey)
            self.eventHotKey = nil
        }
        
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }
}

// Helper extension to convert String to FourCharCode
extension String {
    var fourCharCodeValue: FourCharCode {
        var result: FourCharCode = 0
        if let data = self.data(using: .macOSRoman), data.count == 4 {
            data.withUnsafeBytes { bytes in
                result = bytes.load(as: FourCharCode.self)
            }
        }
        return result
    }
}

// Common key codes for reference
enum KeyCode: UInt32 {
    case space = 49
    case escape = 53
    case returnKey = 36
    case delete = 51
    case leftArrow = 123
    case rightArrow = 124
    case downArrow = 125
    case upArrow = 126
}
