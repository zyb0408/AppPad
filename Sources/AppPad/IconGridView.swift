import SwiftUI
import AppKit

struct IconGridView: View {
    @ObservedObject var viewModel: AppListViewModel
    
    // Dynamic settings from AppStorage (matching SettingsView)
    @AppStorage("iconSize") private var iconSize: Double = 80.0
    @AppStorage("gridColumns") private var gridColumns: Int = 7
    @AppStorage("gridRows") private var gridRows: Int = 5
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(iconSize), spacing: 40), count: gridColumns)
    }
    
    private var appsPerPage: Int {
        gridColumns * gridRows
    }
    
    // Helper to chunk the apps array into pages
    private var pages: [[AppIcon]] {
        viewModel.apps.chunked(into: appsPerPage)
    }
    
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { pageIndex in
                    LazyVGrid(columns: columns, spacing: 40) {
                        ForEach(pages[pageIndex]) { icon in
                            AppIconView(icon: icon, size: iconSize)
                        }
                    }
                    .padding(60)
                    .tag(pageIndex)
                }
            }
            .tabViewStyle(.automatic) // .page doesn't exist on macOS, we use automatic which is usually Tabs, but we can hide tabs or implement custom switcher if needed.
            // On macOS, basic TabView usually shows tabs on top. To mimic Launchpad, we might need a custom pager.
            // Let's stick to a simple TabView for now and see if we can hide tabs, OR build a custom view switcher.
            // Actually, for "Launchpad" look, a horizontal ScrollView with paging is often better, or just standard TabView with tabs hidden.
            // Let's try standard TabView but we might get tabs on top.
            
            // Allow swiping/paging via indicators
            if pages.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .onTapGesture {
                                withAnimation {
                                    currentPage = index
                                }
                            }
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct AppIconView: View {
    let icon: AppIcon
    let size: Double
    @State private var iconImage: NSImage?
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon Image
            Group {
                if let nsImage = iconImage {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.3))
                }
            }
            .frame(width: size, height: size)
            .shadow(radius: 5)
            .onAppear {
                loadIcon()
            }
            
            Text(icon.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(width: size + 20, height: size + 40)
    }
    
    private func loadIcon() {
        // Asynchronously load the icon to avoid main thread hitches during scroll
        DispatchQueue.global(qos: .userInteractive).async {
            let image = NSWorkspace.shared.icon(forFile: icon.iconPath)
            DispatchQueue.main.async {
                self.iconImage = image
            }
        }
    }
}

// Helper extension for chunking
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    ZStack {
        Color.black
        IconGridView(viewModel: AppListViewModel())
    }
}
