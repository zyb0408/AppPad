import SwiftUI

struct IconGridView: View {
    // Mock data for now
    let icons: [AppIcon] = [
        AppIcon(id: UUID(), name: "Finder", bundleIdentifier: "com.apple.finder", iconPath: "", position: 0, folderId: nil),
        AppIcon(id: UUID(), name: "Safari", bundleIdentifier: "com.apple.Safari", iconPath: "", position: 1, folderId: nil),
        AppIcon(id: UUID(), name: "Mail", bundleIdentifier: "com.apple.mail", iconPath: "", position: 2, folderId: nil),
        AppIcon(id: UUID(), name: "Notes", bundleIdentifier: "com.apple.Notes", iconPath: "", position: 3, folderId: nil),
        AppIcon(id: UUID(), name: "Photos", bundleIdentifier: "com.apple.Photos", iconPath: "", position: 4, folderId: nil),
        AppIcon(id: UUID(), name: "Settings", bundleIdentifier: "com.apple.systempreferences", iconPath: "", position: 5, folderId: nil)
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 40)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 40) {
                ForEach(icons) { icon in
                    VStack(spacing: 8) {
                        // Placeholder for Icon
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.gradient)
                            .frame(width: 80, height: 80)
                            .shadow(radius: 5)
                        
                        Text(icon.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    }
                    .frame(width: 100, height: 120)
                }
            }
            .padding(60)
        }
    }
}

#Preview {
    ZStack {
        // Preview background to see the white text
        Color.black
        IconGridView()
    }
}
