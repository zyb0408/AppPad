import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppListViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Material background
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                // Content layer
                VStack(spacing: 0) {
                    // Search Bar - with larger clickable area
                    VStack {
                        SearchField(text: $viewModel.searchText, placeholder: "搜索应用")
                            .frame(width: 400, height: 32)
                    }
                    .frame(height: 120)  // Fixed height for search area
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(16)
                    .padding(.horizontal, 100)
                    .padding(.top, 60)
                    
                    // Icon Grid - constrained to remaining space
                    IconGridView(viewModel: viewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 20)
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
