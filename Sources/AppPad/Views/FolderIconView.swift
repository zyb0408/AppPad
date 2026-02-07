import SwiftUI
import UniformTypeIdentifiers

struct FolderIconView: View {
    let folder: Folder
    let size: Double
    @Binding var isEditMode: Bool
    var onOpen: () -> Void
    var onDropApp: (AppIcon) -> Void
    var onDelete: () -> Void
    @Binding var draggedIcon: AppIcon?

    @State private var isHovering = false
    @State private var isShaking = false

    private var miniSize: Double {
        size * 0.24
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Folder background
                RoundedRectangle(cornerRadius: size * 0.22)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.22)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                    .frame(width: size, height: size)

                // 3x3 mini icon grid
                let previewApps = Array(folder.appIcons.prefix(9))
                let gridColumns = min(3, previewApps.count)
                if !previewApps.isEmpty {
                    LazyVGrid(
                        columns: Array(repeating: SwiftUI.GridItem(.fixed(miniSize), spacing: 3), count: gridColumns),
                        spacing: 3
                    ) {
                        ForEach(previewApps) { app in
                            MiniAppIconView(icon: app, size: miniSize)
                        }
                    }
                    .padding(size * 0.12)
                }
            }
            .frame(width: size, height: size)
            .shadow(radius: 5)
            .scaleEffect(isHovering ? 1.1 : 1.0)
            .animation(.spring(response: 0.2), value: isHovering)
            .overlay(alignment: .topTrailing) {
                if isEditMode {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.red))
                    }
                    .buttonStyle(.plain)
                    .offset(x: 8, y: -8)
                }
            }
            .rotationEffect(.degrees(isShaking ? -2 : 2))
            .contentShape(Rectangle())
            .onTapGesture {
                if !isEditMode {
                    onOpen()
                }
            }
            .onDrop(of: [.text], delegate: FolderDropDelegate(
                folder: folder,
                draggedIcon: $draggedIcon,
                isHovering: $isHovering,
                onDrop: { app in
                    onDropApp(app)
                }
            ))

            Text(folder.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(width: size + 20, height: size + 40)
        .onChange(of: isEditMode) { _, newValue in
            if newValue {
                withAnimation(
                    .easeInOut(duration: 0.12)
                    .repeatForever(autoreverses: true)
                ) {
                    isShaking = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.1)) {
                    isShaking = false
                }
            }
        }
    }
}

// MARK: - Folder Drop Delegate

struct FolderDropDelegate: SwiftUI.DropDelegate {
    let folder: Folder
    @Binding var draggedIcon: AppIcon?
    @Binding var isHovering: Bool
    var onDrop: (AppIcon) -> Void

    func dropEntered(info: DropInfo) {
        isHovering = true
    }

    func dropExited(info: DropInfo) {
        isHovering = false
    }

    func performDrop(info: DropInfo) -> Bool {
        isHovering = false
        guard let app = draggedIcon else { return false }
        onDrop(app)
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
