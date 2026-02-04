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
            Button("打开 AppPad") {
                appDelegate.toggleWindow()
            }
            Divider()
            
            Button("设置...") {
                appDelegate.openSettings()
            }
            
            Divider()
            Button("退出") {
                NSApp.terminate(nil)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindow: MainWindow?
    var settingsWindowController: SettingsWindowController?

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
        
        // Host SwiftUI content with custom hosting view
        let hostingView = ClickableHostingView(rootView: ContentView())
        hostingView.onBackgroundClick = { [weak self] in
            Task { @MainActor in
                self?.toggleWindow()
            }
        }
        window.contentView = hostingView
        
        // Don't show window initially - wait for user to trigger it
        // window.makeKeyAndOrderFront(nil)
        
        self.mainWindow = window
        
        // Register global hotkey (Option + Space)
        GlobalHotkeyManager.shared.registerDefaultHotkey { [weak self] in
            Task { @MainActor in
                self?.toggleWindow()
            }
        }
    }
    
    @MainActor
    func toggleWindow() {
        guard let window = mainWindow else { return }
        WindowAnimationManager.shared.toggleWindow(window)
    }
    
    @MainActor
    func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow(nil)
    }
}
