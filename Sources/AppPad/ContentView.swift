import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppListViewModel()
    @State private var currentPage = 0
    
    // Dynamic settings
    @AppStorage("gridColumns") private var gridColumns: Int = 7
    @AppStorage("gridRows") private var gridRows: Int = 5
    
    private var appsPerPage: Int {
        gridColumns * gridRows
    }
    
    private var pages: [[AppIcon]] {
        viewModel.filteredApps.chunked(into: appsPerPage)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Material background
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Click on background closes the window
                        Task { @MainActor in
                            if let window = NSApp.keyWindow {
                                WindowAnimationManager.shared.hideWindow(window)
                            }
                        }
                    }
                
                // Icon Grid
                IconGridView(viewModel: viewModel, currentPage: $currentPage)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.loadApps()
            
            // Listen for swipe gestures from MainWindow
            NotificationCenter.default.addObserver(
                forName: .swipeLeft,
                object: nil,
                queue: .main
            ) { _ in
                if currentPage > 0 {
                    withAnimation(.easeOut(duration: 0.3)) {
                        currentPage -= 1
                    }
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: .swipeRight,
                object: nil,
                queue: .main
            ) { _ in
                if currentPage < pages.count - 1 {
                    withAnimation(.easeOut(duration: 0.3)) {
                        currentPage += 1
                    }
                }
            }
            
            // Add Esc key monitor
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 { // 53 is Esc
                    // Hide window with animation
                    Task { @MainActor in
                        if let window = NSApp.keyWindow {
                            WindowAnimationManager.shared.hideWindow(window)
                        }
                    }
                    return nil
                }
                return event
            }
        }
    }
}

#Preview {
    ContentView()
}
