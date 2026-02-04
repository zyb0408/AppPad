import SwiftUI

@main
struct AppPadApp: App {
    // Delegate to handle window configuration
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // We use Settings because we are managing the main window manually via NSWindowController/AppDelegate
        // or we can use WindowGroup but hide it/configure it.
        // However, to get EXACTLY the level and behavior requested cleanly, 
        // a pure NSWindow/NSApplicationDelegate approach is often more robust for 'System UI' like apps.
        // But to stick to SwiftUI lifecycle, we can try to use WindowGroup and then introspect,
        // OR just rely on the AppDelegate to spawn the window.
        
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindow: MainWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the window
        let screenRect = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1000, height: 800)
        
        let window = MainWindow(
            contentRect: screenRect,
            // Style mask is set in init but we pass something valid here
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Host SwiftUI content
        window.contentView = NSHostingView(rootView: ContentView())
        
        // Show window
        window.makeKeyAndOrderFront(nil)
        
        // Activate app (so it receives input)
        NSApp.activate(ignoringOtherApps: true)
        
        self.mainWindow = window
    }
}
