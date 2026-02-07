import SwiftUI
import AppKit
import SwiftData

@main
struct AppPadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
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

    private func createModelContainer() -> ModelContainer {
        do {
            return try ModelContainer(
                for: AppIconEntity.self, FolderEntity.self, UserPreferencesEntity.self
            )
        } catch {
            #if DEBUG
            print("Failed to create ModelContainer: \(error), using in-memory store")
            #endif
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            return try! ModelContainer(
                for: AppIconEntity.self, FolderEntity.self, UserPreferencesEntity.self,
                configurations: config
            )
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let container = createModelContainer()

        let screenRect = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1000, height: 800)

        // CRITICAL: Use .borderless only, NOT .fullSizeContentView
        // .fullSizeContentView can interfere with text input in NSPanel
        let window = MainWindow(
            contentRect: screenRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        let contentView = ContentView()
            .modelContainer(container)

        let hostingView = ClickableHostingView(rootView: contentView)
        hostingView.onBackgroundClick = { [weak self] in
            Task { @MainActor in
                self?.toggleWindow()
            }
        }
        window.contentView = hostingView

        self.mainWindow = window

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
