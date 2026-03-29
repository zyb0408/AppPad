import AppKit
import SwiftUI

class MainWindow: NSPanel {

    // Gesture tracking properties
    private var accumulatedDeltaX: CGFloat = 0
    private var accumulatedDeltaY: CGFloat = 0
    private var hasTriggered = false
    private var isGestureActive = false
    private var lastGestureTriggerDate = Date.distantPast

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)

        // NSPanel text input support - CRITICAL settings
        self.becomesKeyOnlyIfNeeded = false
        self.hidesOnDeactivate = false
        self.worksWhenModal = true  // IMPORTANT: Allows text input in panels
        self.isFloatingPanel = true
        self.styleMask.insert(.nonactivatingPanel)  // But allow becoming key

        // 1. Transparent Background
        self.isOpaque = false
        self.backgroundColor = .clear

        // 2. Window Level (Above Dock and other apps)
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.hasShadow = false
        self.isMovableByWindowBackground = false

        // Important: Allow the window to receive events
        self.ignoresMouseEvents = false
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard AppPadInputSettings.isInterfaceGesturesEnabled(),
              event.hasPreciseScrollingDeltas else {
            super.scrollWheel(with: event)
            return
        }

        // Reset on gesture begin
        if event.phase == .began {
            accumulatedDeltaX = 0
            accumulatedDeltaY = 0
            hasTriggered = false
            isGestureActive = true
        }
        
        guard isGestureActive else {
            super.scrollWheel(with: event)
            return
        }
        
        guard !hasTriggered else {
            if event.phase == .ended || event.phase == .cancelled {
                accumulatedDeltaX = 0
                accumulatedDeltaY = 0
                hasTriggered = false
                isGestureActive = false
            }
            return
        }

        let normalizedDeltaX = normalizedDelta(event.scrollingDeltaX, inverted: event.isDirectionInvertedFromDevice)
        let normalizedDeltaY = normalizedDelta(event.scrollingDeltaY, inverted: event.isDirectionInvertedFromDevice)

        accumulatedDeltaX += normalizedDeltaX
        accumulatedDeltaY += normalizedDeltaY
        let threshold: CGFloat = 30.0

        if canTriggerGesture() {
            if abs(accumulatedDeltaX) >= abs(accumulatedDeltaY), abs(accumulatedDeltaX) > threshold {
                if accumulatedDeltaX < 0 {
                    triggerGesture(.swipeLeft)
                } else {
                    triggerGesture(.swipeRight)
                }
                hasTriggered = true
                accumulatedDeltaX = 0
                accumulatedDeltaY = 0
            } else if abs(accumulatedDeltaY) > threshold {
                if accumulatedDeltaY < 0 {
                    triggerGesture(.swipeDown)
                } else {
                    triggerGesture(.swipeUp)
                }
                hasTriggered = true
                accumulatedDeltaX = 0
                accumulatedDeltaY = 0
            }
        }
        
        if event.phase == .ended || event.phase == .cancelled {
            accumulatedDeltaX = 0
            accumulatedDeltaY = 0
            hasTriggered = false
            isGestureActive = false
        }
    }

    override func magnify(with event: NSEvent) {
        guard AppPadInputSettings.isInterfaceGesturesEnabled() else {
            super.magnify(with: event)
            return
        }

        let threshold: CGFloat = 0.08
        guard canTriggerGesture(), abs(event.magnification) > threshold else {
            super.magnify(with: event)
            return
        }

        if event.magnification < 0 {
            triggerGesture(.magnifyIn)
        } else {
            triggerGesture(.magnifyOut)
        }
    }
    
    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
    }

    override func becomeKey() {
        super.becomeKey()
    }

    private func normalizedDelta(_ delta: CGFloat, inverted: Bool) -> CGFloat {
        inverted ? -delta : delta
    }

    private func canTriggerGesture() -> Bool {
        let cooldown = max(UserDefaults.standard.double(forKey: "gestureSensitivity"), 0.1)
        return Date().timeIntervalSince(lastGestureTriggerDate) >= cooldown
    }

    private func triggerGesture(_ kind: AppPadGestureKind) {
        let action = AppPadInputSettings.gestureAction(for: kind)
        lastGestureTriggerDate = Date()

        guard action != .none else { return }

        NotificationCenter.default.post(
            name: .appPadGestureActionTriggered,
            object: nil,
            userInfo: [AppPadInputSettings.gestureActionUserInfoKey: action.rawValue]
        )
    }
}

// Notification names
extension Notification.Name {
    static let swipeLeft = Notification.Name("swipeLeft")
    static let swipeRight = Notification.Name("swipeRight")
}
