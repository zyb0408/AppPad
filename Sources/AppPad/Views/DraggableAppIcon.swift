import SwiftUI
import UniformTypeIdentifiers

struct DraggableAppIcon: View {
    let icon: AppIcon
    let size: Double
    @Binding var draggedIcon: AppIcon?
    @Binding var isEditMode: Bool
    var onLaunch: () -> Void
    var onDrop: (AppIcon, AppIcon) -> Void

    @State private var iconImage: NSImage?
    @State private var isHovering = false
    @State private var isDragging = false
    @State private var showFolderHint = false
    @State private var hoverTimer: DispatchWorkItem?
    @State private var isShaking = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Folder creation hint overlay
                if showFolderHint {
                    RoundedRectangle(cornerRadius: size * 0.22)
                        .fill(.ultraThinMaterial)
                        .frame(width: size * 1.15, height: size * 1.15)
                        .transition(.scale)
                }

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
            }
            .overlay(alignment: .topTrailing) {
                if isEditMode {
                    Button(action: {
                        // Hide app (could be implemented later)
                    }) {
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
            .scaleEffect(isDragging ? 1.2 : (isHovering ? 1.05 : 1.0))
            .opacity(isDragging ? 0.5 : 1.0)
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
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditMode {
                onLaunch()
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            withAnimation(.spring()) {
                isEditMode = true
            }
        }
        .onDrag {
            isDragging = true
            draggedIcon = icon
            return NSItemProvider(object: icon.bundleIdentifier as NSString)
        }
        .onDrop(of: [.text], delegate: AppIconDropDelegate(
            icon: icon,
            draggedIcon: $draggedIcon,
            isHovering: $isHovering,
            showFolderHint: $showFolderHint,
            hoverTimer: $hoverTimer,
            isEditMode: isEditMode,
            onDrop: { source in
                onDrop(source, icon)
                isDragging = false
            }
        ))
        .onChange(of: isEditMode) { _, newValue in
            if newValue {
                startShaking()
            } else {
                stopShaking()
            }
        }
    }

    private func startShaking() {
        withAnimation(
            .easeInOut(duration: 0.12)
            .repeatForever(autoreverses: true)
        ) {
            isShaking = true
        }
    }

    private func stopShaking() {
        withAnimation(.easeOut(duration: 0.1)) {
            isShaking = false
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

// MARK: - Drop Delegate with Hover Timer for Folder Creation

struct AppIconDropDelegate: SwiftUI.DropDelegate {
    let icon: AppIcon
    @Binding var draggedIcon: AppIcon?
    @Binding var isHovering: Bool
    @Binding var showFolderHint: Bool
    @Binding var hoverTimer: DispatchWorkItem?
    let isEditMode: Bool
    var onDrop: (AppIcon) -> Void

    func dropEntered(info: DropInfo) {
        guard draggedIcon?.id != icon.id else { return }
        isHovering = true

        if isEditMode {
            let timer = DispatchWorkItem {
                withAnimation(.spring(response: 0.3)) {
                    showFolderHint = true
                }
            }
            hoverTimer = timer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: timer)
        }
    }

    func dropExited(info: DropInfo) {
        isHovering = false
        hoverTimer?.cancel()
        hoverTimer = nil
        withAnimation {
            showFolderHint = false
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        isHovering = false
        hoverTimer?.cancel()
        hoverTimer = nil
        showFolderHint = false
        guard let source = draggedIcon, source.id != icon.id else { return false }
        onDrop(source)
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
