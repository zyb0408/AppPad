import Foundation
import AppKit
import Carbon

/// Global hotkey manager for AppPad
class GlobalHotkeyManager {
    static let shared = GlobalHotkeyManager()
    
    private var eventHotKey: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var onActivate: (() -> Void)?
    
    private init() {}
    
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
                GlobalHotkeyManager.shared.onActivate?()
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
    
    /// Register default hotkey (Option + Space)
    func registerDefaultHotkey(onActivate: @escaping () -> Void) {
        // Space key = 49, Option = optionKey
        registerHotkey(
            keyCode: 49,
            modifiers: UInt32(optionKey),
            onActivate: onActivate
        )
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

// Modifier flags
extension UInt32 {
    static let cmdKey = UInt32(cmdKey)
    static let shiftKey = UInt32(shiftKey)
    static let optionKey = UInt32(optionKey)
    static let controlKey = UInt32(controlKey)
}
