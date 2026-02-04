import AppKit
import SwiftUI

class MainWindow: NSWindow {
    
    // Gesture tracking properties
    private var accumulatedDeltaX: CGFloat = 0
    private var hasTriggered = false
    private var isGestureActive = false
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        // 1. Transparent Background
        self.isOpaque = false
        self.backgroundColor = .clear
        
        // 2. Window Level (Above Dock and other apps)
        // NSWindow.Level.mainMenu is high, we add 1 to be even higher but just below ScreenSaver/Help usually.
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.hasShadow = false
        self.isMovableByWindowBackground = false
        
        // Important: Allow the window to receive events
        self.ignoresMouseEvents = false
    }
    
    override func scrollWheel(with event: NSEvent) {
        print("MainWindow: scrollWheel called - deltaX: \(event.scrollingDeltaX)")
        
        // Reset on gesture begin
        if event.phase == .began {
            accumulatedDeltaX = 0
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
                hasTriggered = false
                isGestureActive = false
            }
            return
        }
        
        accumulatedDeltaX += event.scrollingDeltaX
        let threshold: CGFloat = 30.0
        
        if accumulatedDeltaX < -threshold {
            print("MainWindow: Swipe Right detected")
            NotificationCenter.default.post(name: .swipeRight, object: nil)
            hasTriggered = true
            accumulatedDeltaX = 0
        } else if accumulatedDeltaX > threshold {
            print("MainWindow: Swipe Left detected")
            NotificationCenter.default.post(name: .swipeLeft, object: nil)
            hasTriggered = true
            accumulatedDeltaX = 0
        }
        
        if event.phase == .ended || event.phase == .cancelled {
            accumulatedDeltaX = 0
            hasTriggered = false
            isGestureActive = false
        }
    }
    
    override var canBecomeKey: Bool {
        print("MainWindow: canBecomeKey called")
        return true
    }
    
    override var canBecomeMain: Bool {
        print("MainWindow: canBecomeMain called")
        return true
    }
    
    override func mouseDown(with event: NSEvent) {
        print("MainWindow: mouseDown called!")
        super.mouseDown(with: event)
    }
    
    override func becomeKey() {
        print("MainWindow: becomeKey called")
        super.becomeKey()
    }
}

// Notification names
extension Notification.Name {
    static let swipeLeft = Notification.Name("swipeLeft")
    static let swipeRight = Notification.Name("swipeRight")
}
