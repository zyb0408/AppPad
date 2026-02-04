import AppKit
import SwiftUI

class MainWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        // 1. Transparent Background
        self.isOpaque = false
        self.backgroundColor = .clear
        
        // 2. Window Level (Above Dock and other apps)
        // NSWindow.Level.mainMenu is high, we add 1 to be even higher but just below ScreenSaver/Help usually.
        // Spec asks for mainMenu + 1.
        self.level = NSWindow.Level(rawValue: Int(NSWindow.Level.mainMenu.rawValue) + 1)
        
        // 3. Collection Behavior
        // .canJoinAllSpaces: visible on all desktops
        // .fullScreenAuxiliary: allows it to be on top of full screen apps
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // 4. Style Mask
        // Borderless to remove title bar, FullSizeContentView to extend content
        self.styleMask = [.borderless, .fullSizeContentView]
        
        // Center and maximize
        if let screen = NSScreen.main {
            self.setFrame(screen.frame, display: true)
        }
        
        // Make it clickable
        self.ignoresMouseEvents = false
    }
}
