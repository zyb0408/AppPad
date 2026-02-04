import SwiftUI

struct ContentView: View {
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
            IconGridView()
        }
    }
}

#Preview {
    ContentView()
}
