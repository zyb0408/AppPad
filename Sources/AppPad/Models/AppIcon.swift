import Foundation

struct AppIcon: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    let bundleIdentifier: String
    var iconPath: String
    var position: Int
    var folderId: UUID?

    static func == (lhs: AppIcon, rhs: AppIcon) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Folder: Identifiable, Codable {
    let id: UUID
    var name: String
    var position: Int
    var appIcons: [AppIcon]

    init(id: UUID = UUID(), name: String = "新建文件夹", position: Int = 0, appIcons: [AppIcon] = []) {
        self.id = id
        self.name = name
        self.position = position
        self.appIcons = appIcons
    }
}

enum GridItem: Identifiable {
    case app(AppIcon)
    case folder(Folder)

    var id: UUID {
        switch self {
        case .app(let icon): return icon.id
        case .folder(let folder): return folder.id
        }
    }

    var position: Int {
        get {
            switch self {
            case .app(let icon): return icon.position
            case .folder(let folder): return folder.position
            }
        }
        set {
            switch self {
            case .app(var icon):
                icon.position = newValue
                self = .app(icon)
            case .folder(var folder):
                folder.position = newValue
                self = .folder(folder)
            }
        }
    }
}
