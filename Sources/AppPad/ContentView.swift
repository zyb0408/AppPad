import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = AppListViewModel()
    @State private var currentPage = 0

    @AppStorage("gridColumns") private var gridColumns: Int = 7
    @AppStorage("gridRows") private var gridRows: Int = 5

    @Environment(\.modelContext) private var modelContext: ModelContext

    private var isSearching: Bool {
        !viewModel.searchText.isEmpty
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Material background
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        handleBackgroundTap()
                    }

                // Main content
                VStack(spacing: 0) {
                    // Search bar
                    SearchBarView(text: $viewModel.searchText)
                        .frame(width: 260)
                        .padding(.top, 50)
                        .padding(.bottom, 10)

                    // Icon Grid
                    IconGridView(viewModel: viewModel, currentPage: $currentPage)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Folder expanded overlay
                if let folder = viewModel.getOpenFolder() {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.closeFolder()
                            }
                        }

                    FolderExpandedView(viewModel: viewModel, folder: folder)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
            viewModel.loadApps()

            // Listen for swipe gestures
            NotificationCenter.default.addObserver(
                forName: .swipeLeft,
                object: nil,
                queue: .main
            ) { _ in
                Task { @MainActor in
                    if currentPage > 0 {
                        withAnimation(.easeOut(duration: 0.3)) {
                            currentPage -= 1
                        }
                    }
                }
            }

            NotificationCenter.default.addObserver(
                forName: .swipeRight,
                object: nil,
                queue: .main
            ) { _ in
                Task { @MainActor in
                    let pages = viewModel.gridItems.chunked(into: gridColumns * gridRows)
                    if currentPage < pages.count - 1 {
                        withAnimation(.easeOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    }
                }
            }

            // Window hide notification - reset search
            NotificationCenter.default.addObserver(
                forName: .appPadWindowDidHide,
                object: nil,
                queue: .main
            ) { _ in
                Task { @MainActor in
                    viewModel.searchText = ""
                    viewModel.isEditMode = false
                    viewModel.closeFolder()
                }
            }

            // Window show notification - auto-focus search
            NotificationCenter.default.addObserver(
                forName: .appPadWindowDidShow,
                object: nil,
                queue: .main
            ) { _ in
                Task { @MainActor in
                    SearchBarView.focusSearchField()
                }
            }

            // Keyboard monitor: Esc + type-anywhere search
            // Now safe to enable since NSPanel configuration is fixed
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                return handleKeyEvent(event)
            }
        }
        .onChange(of: viewModel.searchText) { _, newValue in
            if !newValue.isEmpty {
                withAnimation {
                    currentPage = 0
                }
            }
        }
    }

    private func handleBackgroundTap() {
        if viewModel.openFolderId != nil {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                viewModel.closeFolder()
            }
        } else if viewModel.isEditMode {
            withAnimation(.spring()) {
                viewModel.isEditMode = false
            }
        } else {
            Task { @MainActor in
                if let window = NSApp.keyWindow {
                    WindowAnimationManager.shared.hideWindow(window)
                }
            }
        }
    }

    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        // If any TextField is focused (SwiftUI TextField), let it handle the event
        // Check for NSTextView which SwiftUI TextField uses internally
        if let firstResponder = NSApp.keyWindow?.firstResponder {
            if firstResponder is NSTextView || firstResponder is NSText {
                return event // Let the TextField handle it
            }
        }
        
        // Esc key
        if event.keyCode == 53 {
            if !viewModel.searchText.isEmpty {
                viewModel.searchText = ""
                return nil
            }
            if viewModel.openFolderId != nil {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.closeFolder()
                }
                return nil
            }
            if viewModel.isEditMode {
                withAnimation(.spring()) {
                    viewModel.isEditMode = false
                }
                return nil
            }
            Task { @MainActor in
                if let window = NSApp.keyWindow {
                    WindowAnimationManager.shared.hideWindow(window)
                }
            }
            return nil
        }

        // Type-anywhere: auto-focus search field on printable characters
        if let chars = event.characters, !chars.isEmpty {
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
                .subtracting([.shift, .capsLock])
            if modifiers.isEmpty || modifiers == .shift {
                let firstChar = chars.unicodeScalars.first!
                if CharacterSet.alphanumerics.union(.whitespaces).contains(firstChar) ||
                   firstChar.value > 127 {
                    if !SearchBarView.isSearchFieldFocused {
                        // Manually append the first character and schedule focus
                        viewModel.searchText.append(chars)
                        SearchBarView.focusSearchField()
                        return nil // Consume: we handled it manually
                    }
                    return event // Already focused, let AppKit handle it
                }
            }
        }

        return event
    }
}

#Preview {
    ContentView()
}
