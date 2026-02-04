import Foundation

struct AppIcon: Identifiable, Codable {
    let id: UUID
    let name: String
    let bundleIdentifier: String
    let iconPath: String
    var position: Int // Used for sorting
    var folderId: UUID? // If it belongs to a folder
}
