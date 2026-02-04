import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppListViewModel()
    
    var body: some View {
        ZStack {
            // Background layer - catches all clicks
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    // Any click on background closes the window
                    Task { @MainActor in
                        if let window = NSApp.keyWindow {
                            WindowAnimationManager.shared.hideWindow(window)
                        }
                    }
                }
            
            // Material background (non-interactive)
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            // Content layer - blocks clicks from reaching background
            VStack(spacing: 20) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.8))
                    
                    SearchField(text: $viewModel.searchText, placeholder: "搜索应用")
                        .frame(height: 22)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.2))
                .cornerRadius(12)
                .frame(width: 300)
                .padding(.top, 40)
                .onTapGesture {
                    // Prevent background tap when clicking search bar
                }
                
                IconGridView(viewModel: viewModel)
                    .onTapGesture {
                        // Prevent background tap when clicking grid area
                        // Individual icon taps are handled in IconGridView
                    }
            }
        }
        .onAppear {
            viewModel.loadApps()
            
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
