import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppListViewModel()
    
    var body: some View {
        ZStack {
            // Material background
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            // Content layer
            VStack(spacing: 20) {
                // Search Bar
                SearchField(text: $viewModel.searchText, placeholder: "搜索应用")
                    .frame(width: 300, height: 28)
                    .padding(.top, 40)
                
                IconGridView(viewModel: viewModel)
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
