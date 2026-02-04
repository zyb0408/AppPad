import AppKit
import SwiftUI

/// Manages window animations for AppPad
class WindowAnimationManager {
    static let shared = WindowAnimationManager()
    
    private init() {}
    
    /// Show window with animation (zoom + fade in)
    func showWindow(_ window: NSWindow, completion: (() -> Void)? = nil) {
        guard !window.isVisible else {
            completion?()
            return
        }
        
        // Get screen center
        guard let screen = NSScreen.main else {
            window.makeKeyAndOrderFront(nil)
            completion?()
            return
        }
        
        let screenFrame = screen.frame
        let windowFrame = window.frame
        
        // Calculate center point
        let centerX = screenFrame.midX - windowFrame.width / 2
        let centerY = screenFrame.midY - windowFrame.height / 2
        
        // Start from center with small scale
        let startFrame = NSRect(
            x: screenFrame.midX - 100,
            y: screenFrame.midY - 100,
            width: 200,
            height: 200
        )
        
        window.setFrame(startFrame, display: false)
        window.alphaValue = 0.0
        window.makeKeyAndOrderFront(nil)
        
        // Animate to full size
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().setFrame(screenFrame, display: true)
            window.animator().alphaValue = 1.0
        }, completionHandler: {
            completion?()
        })
    }
    
    /// Hide window with animation (zoom + fade out)
    func hideWindow(_ window: NSWindow, completion: (() -> Void)? = nil) {
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
        
        // Target small frame at center
        let targetFrame = NSRect(
            x: screenFrame.midX - 100,
            y: screenFrame.midY - 100,
            width: 200,
            height: 200
        )
        
        // Animate to small size and fade out
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().setFrame(targetFrame, display: true)
            window.animator().alphaValue = 0.0
        }, completionHandler: {
            window.orderOut(nil)
            // Reset to full screen for next show
            window.setFrame(screenFrame, display: false)
            window.alphaValue = 1.0
            completion?()
        })
    }
    
    /// Toggle window with animation
    func toggleWindow(_ window: NSWindow) {
        if window.isVisible {
            hideWindow(window)
        } else {
            showWindow(window)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
