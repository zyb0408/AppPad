import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppListViewModel()
    
    var body: some View {
        ZStack {
            // Background tap to close
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    // Click background to hide with animation
                    if let window = NSApp.keyWindow {
                        WindowAnimationManager.shared.hideWindow(window)
                    }
                }
            
            // 1. Ultra Thin Material Background
            // This relies on the window behind it being transparent to show the desktop through,
            // but effectively 'regular' material in SwiftUI creates a blur effect.
            // For true window-level blur, we often rely on the NSVisualEffectView backing using .visualEffect material,
            // but strict SwiftUI usage is Color.clear + .background(.ultraThinMaterial)
            
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            // 2. Icon Grid & Search
            VStack(spacing: 20) {
                // Search Bar
                HStack {
                    // We use the native SearchField which includes the glass icon logic usually, 
                    // but since we want custom styling, we'll keep the icon outside or let NSSearchField handle it?
                    // NSSearchField has its own glass icon. Let's use that for standard feel, 
                    // OR stick to our styling: Icon + Input.
                    // Our SearchField wrapper is unbordered.
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.8))
                    
                    SearchField(text: $viewModel.searchText, placeholder: "Search Apps")
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
            .allowsHitTesting(true)
        }
        .onAppear {
            viewModel.loadApps()
            
            // Add Esc key monitor
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 { // 53 is Esc
                    // Hide window with animation
                    if let window = NSApp.keyWindow {
                        WindowAnimationManager.shared.hideWindow(window)
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
