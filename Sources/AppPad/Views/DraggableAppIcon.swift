import SwiftUI
import UniformTypeIdentifiers

/// Drag and drop support for app icons
struct DraggableAppIcon: View {
    let icon: AppIcon
    let size: Double
    @Binding var draggedIcon: AppIcon?
    @Binding var isEditMode: Bool
    var onLaunch: () -> Void
    var onDrop: (AppIcon, AppIcon) -> Void // (source, target)
    
    @State private var iconImage: NSImage?
    @State private var isHovering = false
    @State private var isDragging = false
    @State private var longPressTimer: Timer?
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon Image with shake animation in edit mode
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
            .overlay(alignment: .topTrailing) {
                // Delete button in edit mode
                if isEditMode {
                    Button(action: {
                        // TODO: Implement delete
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
            .rotationEffect(isEditMode ? shakeAngle() : .degrees(0))
            .animation(isEditMode ? shakeAnimation() : .default, value: isEditMode)
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
            // Enter edit mode on long press
            withAnimation(.spring()) {
                isEditMode = true
            }
        }
        .onDrag {
            isDragging = true
            draggedIcon = icon
            return NSItemProvider(object: icon.bundleIdentifier as NSString)
        }
        .onDrop(of: [.text], delegate: DropDelegate(
            icon: icon,
            draggedIcon: $draggedIcon,
            isHovering: $isHovering,
            onDrop: { source in
                onDrop(source, icon)
                isDragging = false
            }
        ))
    }
    
    private func loadIcon() {
        DispatchQueue.global(qos: .userInteractive).async {
            let image = NSWorkspace.shared.icon(forFile: icon.iconPath)
            DispatchQueue.main.async {
                self.iconImage = image
            }
        }
    }
    
    // Shake animation for edit mode
    private func shakeAngle() -> Angle {
        let angles: [Double] = [-2, 2, -2, 2, -2]
        return .degrees(angles.randomElement() ?? 0)
    }
    
    private func shakeAnimation() -> Animation {
        Animation.easeInOut(duration: 0.1)
            .repeatForever(autoreverses: true)
    }
}

struct DropDelegate: SwiftUI.DropDelegate {
    let icon: AppIcon
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
        guard let draggedIcon = draggedIcon else { return false }
        onDrop(draggedIcon)
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
