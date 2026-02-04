import SwiftUI
import AppKit

struct IconGridView: View {
    @ObservedObject var viewModel: AppListViewModel
    
    // Dynamic settings from AppStorage (matching SettingsView)
    @AppStorage("iconSize") private var iconSize: Double = 80.0
    @AppStorage("gridColumns") private var gridColumns: Int = 7
    @AppStorage("gridRows") private var gridRows: Int = 5
    @AppStorage("gestureSensitivity") private var gestureSensitivity: Double = 0.5
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(iconSize), spacing: 40), count: gridColumns)
    }
    
    private var appsPerPage: Int {
        gridColumns * gridRows
    }
    
    // Helper to chunk the apps array into pages
    private var pages: [[AppIcon]] {
        viewModel.filteredApps.chunked(into: appsPerPage)
    }
    
    @State private var currentPage = 0
    @State private var lastGestureTime: Date = Date.distantPast
    
    var body: some View {
        ZStack {
            // Gesture Layer: Fills the entire view to capture swipes
            PageGestureView(
                onSwipeLeft: {
                    let now = Date()
                    if now.timeIntervalSince(lastGestureTime) > gestureSensitivity {
                        if currentPage > 0 {
                            withAnimation(.easeOut(duration: 0.3)) { currentPage -= 1 }
                        }
                        lastGestureTime = now
                    }
                },
                onSwipeRight: {
                    let now = Date()
                    if now.timeIntervalSince(lastGestureTime) > gestureSensitivity {
                        if currentPage < pages.count - 1 {
                            withAnimation(.easeOut(duration: 0.3)) { currentPage += 1 }
                        }
                        lastGestureTime = now
                    }
                }
            )
            
            VStack {
                // Content with Offset for Pagination
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        ForEach(0..<pages.count, id: \.self) { pageIndex in
                            LazyVGrid(columns: columns, spacing: 40) {
                                ForEach(pages[pageIndex]) { icon in
                                    AppIconView(icon: icon, size: iconSize)
                                        .onTapGesture {
                                            launchApp(icon)
                                        }
                                }
                            }
                            .padding(60)
                            .frame(width: geometry.size.width)
                        }
                    }
                    .offset(x: -CGFloat(currentPage) * geometry.size.width)
                }
                
                // Page Indicators
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
    
    private func launchApp(_ icon: AppIcon) {
        let url = URL(fileURLWithPath: icon.iconPath)
        NSWorkspace.shared.open(url)
        // Hide the window after launching
        Task { @MainActor in
            NSApp.hide(nil)
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
