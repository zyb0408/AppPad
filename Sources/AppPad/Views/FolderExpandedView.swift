import SwiftUI
import AppKit

struct FolderExpandedView: View {
    @ObservedObject var viewModel: AppListViewModel
    let folder: Folder

    @AppStorage("iconSize") private var iconSize: Double = 80.0
    @State private var folderName: String = ""

    private var displayColumns: Int {
        let count = folder.appIcons.count
        if count <= 3 { return count }
        if count <= 9 { return 3 }
        return 4
    }

    var body: some View {
        VStack(spacing: 16) {
            // Editable folder name
            TextField("文件夹名称", text: $folderName)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .padding(.horizontal, 20)
                .onChange(of: folderName) { _, newValue in
                    viewModel.renameFolder(folderId: folder.id, name: newValue)
                }

            Divider()
                .background(Color.white.opacity(0.2))

            // Scrollable grid of apps
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: SwiftUI.GridItem(.fixed(iconSize), spacing: 30), count: displayColumns),
                    spacing: 20
                ) {
                    ForEach(folder.appIcons) { icon in
                        AppIconView(icon: icon, size: iconSize)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                launchApp(icon)
                            }
                            .contextMenu {
                                Button("从文件夹移出") {
                                    viewModel.removeAppFromFolder(app: icon, folderId: folder.id)
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(maxHeight: 400)
        }
        .padding(.top, 24)
        .padding(.bottom, 16)
        .frame(width: max(CGFloat(displayColumns) * (iconSize + 50) + 40, 300))
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(.ultraThickMaterial)
                .shadow(radius: 30)
        )
        .onAppear {
            folderName = folder.name
        }
        .onChange(of: folder.id) { _, _ in
            folderName = folder.name
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
