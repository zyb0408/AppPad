import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct IconGridView: View {
    @ObservedObject var viewModel: AppListViewModel
    @Binding var currentPage: Int

    @AppStorage("iconSize") private var iconSize: Double = 80.0
    @AppStorage("gridColumns") private var gridColumns: Int = 7
    @AppStorage("gridRows") private var gridRows: Int = 5

    private var columns: [SwiftUI.GridItem] {
        Array(repeating: SwiftUI.GridItem(.fixed(iconSize), spacing: 40), count: gridColumns)
    }

    private var appsPerPage: Int {
        gridColumns * gridRows
    }

    private var pages: [[GridItem]] {
        viewModel.gridItems.chunked(into: appsPerPage)
    }

    private var isSearching: Bool {
        !viewModel.searchText.isEmpty
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                if pages.isEmpty {
                    VStack {
                        Spacer()
                        if isSearching {
                            Text("无搜索结果")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        } else if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    HStack(spacing: 0) {
                        ForEach(0..<pages.count, id: \.self) { pageIndex in
                            LazyVGrid(columns: columns, spacing: 40) {
                                ForEach(pages[pageIndex]) { item in
                                    gridItemView(for: item)
                                }
                            }
                            .padding(60)
                            .frame(width: geometry.size.width)
                        }
                    }
                    .offset(x: -CGFloat(currentPage) * geometry.size.width)
                }
            }

            // Page indicators (hidden during search)
            if pages.count > 1 && !isSearching {
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

    @ViewBuilder
    private func gridItemView(for item: GridItem) -> some View {
        switch item {
        case .app(let icon):
            DraggableAppIcon(
                icon: icon,
                size: iconSize,
                draggedIcon: $viewModel.draggedIcon,
                isEditMode: $viewModel.isEditMode,
                onLaunch: {
                    launchApp(icon)
                },
                onDrop: { source, target in
                    viewModel.handleDrop(source: source, target: target)
                }
            )
        case .folder(let folder):
            FolderIconView(
                folder: folder,
                size: iconSize,
                isEditMode: $viewModel.isEditMode,
                onOpen: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.openFolder(folderId: folder.id)
                    }
                },
                onDropApp: { app in
                    viewModel.addAppToFolder(app: app, folderId: folder.id)
                },
                onDelete: {
                    viewModel.deleteFolder(folderId: folder.id)
                },
                draggedIcon: $viewModel.draggedIcon
            )
        }
    }

    private func launchApp(_ icon: AppIcon) {
        let url = URL(fileURLWithPath: icon.iconPath)
        NSWorkspace.shared.open(url)
        Task { @MainActor in
            NSApp.hide(nil)
        }
    }
}

// MARK: - App Icon View (simplified, used in folder expanded view)

struct AppIconView: View {
    let icon: AppIcon
    let size: Double
    @State private var iconImage: NSImage?

    var body: some View {
        VStack(spacing: 8) {
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
        DispatchQueue.global(qos: .userInteractive).async {
            let image = NSWorkspace.shared.icon(forFile: icon.iconPath)
            DispatchQueue.main.async {
                self.iconImage = image
            }
        }
    }
}

// MARK: - Mini App Icon (used in folder preview)

struct MiniAppIconView: View {
    let icon: AppIcon
    let size: Double
    @State private var iconImage: NSImage?

    var body: some View {
        Group {
            if let nsImage = iconImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
        .onAppear {
            loadIcon()
        }
    }

    private func loadIcon() {
        DispatchQueue.global(qos: .userInteractive).async {
            let image = NSWorkspace.shared.icon(forFile: icon.iconPath)
            DispatchQueue.main.async {
                self.iconImage = image
            }
        }
    }
}

// MARK: - Array Extension

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var currentPage = 0

        var body: some View {
            ZStack {
                Color.black
                IconGridView(viewModel: AppListViewModel(), currentPage: $currentPage)
            }
        }
    }

    return PreviewWrapper()
}
