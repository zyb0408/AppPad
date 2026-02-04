import AppKit
import SwiftUI

/// Custom settings window controller to ensure settings window appears on top
class SettingsWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "AppPad 设置"
        window.center()
        
        // Set window level to float above other windows
        window.level = .floating
        
        // Make it appear in all spaces
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Set content
        window.contentView = NSHostingView(rootView: SettingsView())
        
        self.init(window: window)
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
