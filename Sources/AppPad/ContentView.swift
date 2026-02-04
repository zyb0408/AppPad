import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppListViewModel()
    
    var body: some View {
        ZStack {
            // 1. Ultra Thin Material Background
            // This relies on the window behind it being transparent to show the desktop through,
            // but effectively 'regular' material in SwiftUI creates a blur effect.
            // For true window-level blur, we often rely on the NSVisualEffectView backing using .visualEffect material,
            // but strict SwiftUI usage is Color.clear + .background(.ultraThinMaterial)
            
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            // 2. Icon Grid
            IconGridView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadApps()
            
            // Add Esc key monitor
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 { // 53 is Esc
                    NSApp.terminate(nil)
                    return nil
                }
                return event
            }
        }
        .onTapGesture {
            // Click outside grid to close
            NSApp.terminate(nil)
        }
    }
}

#Preview {
    ContentView()
}
