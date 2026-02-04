import SwiftUI
import AppKit

@main
struct AppPadApp: App {
    // Delegate to handle window configuration
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // We use Settings because we are managing the main window manually via NSWindowController/AppDelegate
        Settings {
            SettingsView()
        }
        
        // Menu Bar Icon
        MenuBarExtra("AppPad", systemImage: "square.grid.3x3.fill") {
            Button("Toggle AppPad") {
                appDelegate.toggleWindow()
            }
            Divider()
            
            // Standard Settings Link
            if #available(macOS 14.0, *) {
                 SettingsLink {
                     Text("Settings...")
                 }
            } else {
                Button("Settings...") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
            }
            
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
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
    
    @MainActor
    func toggleWindow() {
        guard let window = mainWindow else { return }
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
