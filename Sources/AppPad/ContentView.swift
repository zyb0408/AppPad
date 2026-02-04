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
                
                // Icon Grid - full screen
                IconGridView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
