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
            
            // 2. Icon Grid & Search
            VStack(spacing: 20) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.8))
                    
                    ZStack(alignment: .leading) {
                        if viewModel.searchText.isEmpty {
                            Text("Search Apps")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        TextField("", text: $viewModel.searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.white)
                    }
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
