import AppKit
import SwiftUI

@MainActor
final class WindowAnimationManager: @unchecked Sendable {
    static let shared = WindowAnimationManager()

    private init() {}

    private var animationDuration: TimeInterval {
        max(UserDefaults.standard.object(forKey: "animationSpeed") as? Double ?? 0.2, 0.1)
    }

    func showWindow(_ window: NSWindow, completion: (@Sendable () -> Void)? = nil) {
        guard !window.isVisible else {
            completion?()
            return
        }

        guard let screen = NSScreen.main else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            completion?()
            return
        }

        let screenFrame = screen.frame

        let startFrame = NSRect(
            x: screenFrame.midX - 100,
            y: screenFrame.midY - 100,
            width: 200,
            height: 200
        )

        window.setFrame(startFrame, display: false)
        window.alphaValue = 0.0
        
        // CRITICAL: Make window key and activate app BEFORE animation
        // This ensures keyboard input goes to the window, not the terminal
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().setFrame(screenFrame, display: true)
            window.animator().alphaValue = 1.0
        }, completionHandler: {
            Task { @MainActor in
                NotificationCenter.default.post(name: .appPadWindowDidShow, object: nil)
                completion?()
            }
        })
    }

    func hideWindow(_ window: NSWindow, completion: (@Sendable () -> Void)? = nil) {
        guard window.isVisible else {
            completion?()
            return
        }

        guard let screen = NSScreen.main else {
            window.orderOut(nil)
            completion?()
            return
        }

        let screenFrame = screen.frame

        let targetFrame = NSRect(
            x: screenFrame.midX - 100,
            y: screenFrame.midY - 100,
            width: 200,
            height: 200
        )

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().setFrame(targetFrame, display: true)
            window.animator().alphaValue = 0.0
        }, completionHandler: {
            Task { @MainActor in
                window.orderOut(nil)
                window.setFrame(screenFrame, display: false)
                window.alphaValue = 1.0
                NotificationCenter.default.post(name: .appPadWindowDidHide, object: nil)
                completion?()
            }
        })
    }

    func toggleWindow(_ window: NSWindow) {
        if window.isVisible {
            hideWindow(window)
        } else {
            showWindow(window)
        }
    }
}

extension Notification.Name {
    static let appPadWindowDidHide = Notification.Name("appPadWindowDidHide")
    static let appPadWindowDidShow = Notification.Name("appPadWindowDidShow")
}
