import Foundation
import SwiftData

@Model
final class AppIconEntity {
    @Attribute(.unique) var bundleIdentifier: String
    var name: String
    var iconPath: String
    var position: Int
    var pageIndex: Int
    var folderId: UUID?
    var isHidden: Bool
    var lastUpdated: Date
    
    init(bundleIdentifier: String, name: String, iconPath: String, position: Int, pageIndex: Int = 0, folderId: UUID? = nil, isHidden: Bool = false) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.iconPath = iconPath
        self.position = position
        self.pageIndex = pageIndex
        self.folderId = folderId
        self.isHidden = isHidden
        self.lastUpdated = Date()
    }
    
    func toAppIcon() -> AppIcon {
        return AppIcon(
            id: UUID(), // Generate new UUID each time for SwiftUI
            name: name,
            bundleIdentifier: bundleIdentifier,
            iconPath: iconPath,
            position: position,
            folderId: folderId
        )
    }
}

@Model
final class FolderEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var position: Int
    var pageIndex: Int
    var color: String // Hex color code
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, position: Int, pageIndex: Int = 0, color: String = "#007AFF") {
        self.id = id
        self.name = name
        self.position = position
        self.pageIndex = pageIndex
        self.color = color
        self.createdAt = Date()
    }
}

@Model
final class UserPreferencesEntity {
    @Attribute(.unique) var id: String
    var iconSize: Double
    var gridColumns: Int
    var gridRows: Int
    var gestureSensitivity: Double
    var globalShortcutEnabled: Bool
    var globalShortcutKey: String
    var hotCornerEnabled: Bool
    var hotCornerPosition: String
    var backgroundBlurIntensity: Double
    var animationSpeed: Double
    var launchAtLogin: Bool
    
    init(id: String = "default") {
        self.id = id
        self.iconSize = 80.0
        self.gridColumns = 7
        self.gridRows = 5
        self.gestureSensitivity = 0.5
        self.globalShortcutEnabled = true
        self.globalShortcutKey = "Option+Space"
        self.hotCornerEnabled = false
        self.hotCornerPosition = "bottomLeft"
        self.backgroundBlurIntensity = 1.0
        self.animationSpeed = 0.3
        self.launchAtLogin = false
    }
}
