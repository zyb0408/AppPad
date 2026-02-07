import AppKit
import SwiftUI

@MainActor
final class WindowAnimationManager: @unchecked Sendable {
    static let shared = WindowAnimationManager()

    private init() {}

    func showWindow(_ window: NSWindow, completion: (@Sendable () -> Void)? = nil) {
        guard !window.isVisible else {
            completion?()
            return
        }

        guard let screen = NSScreen.main else {
            window.makeKeyAndOrderFront(nil)
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
        window.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
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
            context.duration = 0.25
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
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

extension Notification.Name {
    static let appPadWindowDidHide = Notification.Name("appPadWindowDidHide")
    static let appPadWindowDidShow = Notification.Name("appPadWindowDidShow")
}
