import SwiftUI
import AppKit

struct IconGridView: View {
    @ObservedObject var viewModel: AppListViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 40)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 40) {
                ForEach(viewModel.apps) { icon in
                    AppIconView(icon: icon)
                }
            }
            .padding(60)
        }
    }
}

struct AppIconView: View {
    let icon: AppIcon
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
            .frame(width: 80, height: 80)
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
        .frame(width: 100, height: 120)
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

#Preview {
    ZStack {
        // Preview background to see the white text
        Color.black
        IconGridView(viewModel: AppListViewModel())
    }
}
