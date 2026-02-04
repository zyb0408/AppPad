import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppListViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Ultra Thin Material Background
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                // 2. Icon Grid & Search
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
                    
                    IconGridView(viewModel: viewModel)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                // Check if tap is outside the content area
                let contentWidth = geometry.size.width * 0.8
                let contentHeight = geometry.size.height * 0.8
                let contentX = (geometry.size.width - contentWidth) / 2
                let contentY = (geometry.size.height - contentHeight) / 2
                
                let contentRect = CGRect(
                    x: contentX,
                    y: contentY,
                    width: contentWidth,
                    height: contentHeight
                )
                
                if !contentRect.contains(location) {
                    // Click outside content area - hide window
                    Task { @MainActor in
                        if let window = NSApp.keyWindow {
                            WindowAnimationManager.shared.hideWindow(window)
                        }
                    }
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
