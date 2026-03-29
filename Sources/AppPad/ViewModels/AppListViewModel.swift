import SwiftUI
import Combine
import SwiftData

@MainActor
class AppListViewModel: ObservableObject {
    // App data
    @Published var apps: [AppIcon] = []
    @Published var folders: [Folder] = []
    @Published var gridItems: [GridItem] = []
    @Published var isLoading = false
    @Published var searchText = ""

    // Edit & drag state
    @Published var isEditMode = false
    @Published var openFolderId: UUID? = nil
    @Published var draggedIcon: AppIcon? = nil

    private let scanner = AppScanner()
    private var cancellables = Set<AnyCancellable>()
    private var modelContext: ModelContext?

    init() {
        $searchText
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.filterApps(text)
            }
            .store(in: &cancellables)
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Search / Filter

    private func filterApps(_ text: String) {
        let normalizedQuery = text.normalizedSearchText()

        guard !normalizedQuery.isEmpty else {
            rebuildGridItems()
            return
        }

        // Search mode: search ALL apps including those in folders
        let allApps = allAppsFlat()
        let matched = allApps.filter { app in
            for candidate in [app.name] + app.searchAliases {
                let normalizedCandidate = candidate.normalizedSearchText()
                if normalizedCandidate.contains(normalizedQuery) {
                    return true
                }

                let pinyin = candidate.transformToPinyin()
                if pinyin.contains(normalizedQuery) {
                    return true
                }

                let initials = candidate.transformToPinyinInitials()
                if initials.contains(normalizedQuery) {
                    return true
                }
            }

            return false
        }

        gridItems = matched.map { .app($0) }
    }

    private func allAppsFlat() -> [AppIcon] {
        var all = apps.filter { $0.folderId == nil }
        for folder in folders {
            all.append(contentsOf: folder.appIcons)
        }
        return all
    }
    
    /// Open the first app in the current search results
    func openFirstSearchResult() {
        // Only works when searching
        guard !searchText.isEmpty else { return }
        
        // Get the first app from grid items
        if let firstItem = gridItems.first {
            switch firstItem {
            case .app(let appIcon):
                launchApp(appIcon)
            case .folder:
                // If it's a folder, we don't open it on Enter
                break
            }
        }
    }
    
    /// Launch an app by its AppIcon
    func launchApp(_ app: AppIcon) {
        let url = URL(fileURLWithPath: app.iconPath)
        NSWorkspace.shared.open(url)
        
        // Hide window after launching
        if let window = NSApp.keyWindow {
            WindowAnimationManager.shared.hideWindow(window)
        }
        
        // Clear search text
        searchText = ""
    }

    // MARK: - Grid Rebuild

    func rebuildGridItems() {
        var items: [GridItem] = []
        items += apps.filter { $0.folderId == nil }.map { .app($0) }
        items += folders.map { .folder($0) }
        items.sort { $0.position < $1.position }
        gridItems = items
    }

    // MARK: - Load Apps

    func loadApps() {
        guard !isLoading else { return }
        isLoading = true

        Task {
            let foundApps = await scanner.scanApplications()

            // Try to load persisted state
            if let context = modelContext {
                loadFromPersistence(context: context, scannedApps: foundApps)
            } else {
                self.apps = foundApps
                self.folders = []
            }

            rebuildGridItems()
            self.isLoading = false
        }
    }
    
    /// Refresh app list to detect newly installed or removed apps
    /// This preserves folder structure and app positions
    func refreshApps() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            let scannedApps = await scanner.scanApplications()
            let scannedBundleIds = Set(scannedApps.map { $0.bundleIdentifier })
            
            // Get all current app bundle IDs (both in root and in folders)
            var currentBundleIds = Set(apps.map { $0.bundleIdentifier })
            for folder in folders {
                currentBundleIds.formUnion(folder.appIcons.map { $0.bundleIdentifier })
            }
            
            // Find new apps (installed since last load)
            let newBundleIds = scannedBundleIds.subtracting(currentBundleIds)
            let newApps = scannedApps.filter { newBundleIds.contains($0.bundleIdentifier) }
            
            // Find removed apps (uninstalled since last load)
            let removedBundleIds = currentBundleIds.subtracting(scannedBundleIds)
            
            var hasChanges = false
            
            // Add new apps to root level
            if !newApps.isEmpty {
                let maxPosition = (gridItems.map { $0.position }.max() ?? 0) + 1
                for (index, var newApp) in newApps.enumerated() {
                    newApp.position = maxPosition + index
                    newApp.folderId = nil
                    apps.append(newApp)
                }
                hasChanges = true
                print("AppPad: Added \(newApps.count) new app(s)")
            }
            
            // Remove uninstalled apps from root
            if !removedBundleIds.isEmpty {
                let beforeCount = apps.count
                apps.removeAll { removedBundleIds.contains($0.bundleIdentifier) }
                
                // Remove from folders
                for i in folders.indices {
                    folders[i].appIcons.removeAll { removedBundleIds.contains($0.bundleIdentifier) }
                }
                
                // Clean up empty folders
                folders.removeAll { $0.appIcons.isEmpty }
                
                if apps.count != beforeCount {
                    hasChanges = true
                    print("AppPad: Removed \(removedBundleIds.count) uninstalled app(s)")
                }
            }
            
            // Update app icons for existing apps (in case icons changed)
            let scannedAppMap = Dictionary(uniqueKeysWithValues: scannedApps.map { ($0.bundleIdentifier, $0) })
            for i in apps.indices {
                if let updated = scannedAppMap[apps[i].bundleIdentifier] {
                    if apps[i].name != updated.name ||
                        apps[i].iconPath != updated.iconPath ||
                        apps[i].searchAliases != updated.searchAliases {
                        apps[i].name = updated.name
                        apps[i].iconPath = updated.iconPath
                        apps[i].searchAliases = updated.searchAliases
                        hasChanges = true
                    }
                }
            }
            for i in folders.indices {
                for j in folders[i].appIcons.indices {
                    if let updated = scannedAppMap[folders[i].appIcons[j].bundleIdentifier] {
                        if folders[i].appIcons[j].name != updated.name ||
                            folders[i].appIcons[j].iconPath != updated.iconPath ||
                            folders[i].appIcons[j].searchAliases != updated.searchAliases {
                            folders[i].appIcons[j].name = updated.name
                            folders[i].appIcons[j].iconPath = updated.iconPath
                            folders[i].appIcons[j].searchAliases = updated.searchAliases
                            hasChanges = true
                        }
                    }
                }
            }
            
            if hasChanges {
                reindexPositions()
                rebuildGridItems()
                saveToPersistence()
            }
            
            self.isLoading = false
        }
    }

    // MARK: - Folder CRUD

    func createFolder(from sourceApp: AppIcon, onto targetApp: AppIcon) {
        let folderName = suggestFolderName(for: [sourceApp, targetApp])
        let targetPosition = targetApp.position

        var source = sourceApp
        source.folderId = nil
        source.position = 0

        var target = targetApp
        target.folderId = nil
        target.position = 1

        let folder = Folder(
            name: folderName,
            position: targetPosition,
            appIcons: [target, source]
        )

        // Remove apps from root grid
        apps.removeAll { $0.id == sourceApp.id || $0.id == targetApp.id }

        // Update folderId on the original apps array
        folders.append(folder)

        // Reindex positions
        reindexPositions()
        rebuildGridItems()
        saveToPersistence()
    }

    func addAppToFolder(app: AppIcon, folderId: UUID) {
        guard let folderIndex = folders.firstIndex(where: { $0.id == folderId }) else { return }

        // Remove from root
        apps.removeAll { $0.id == app.id }

        // Also check if it's already in another folder
        for i in folders.indices {
            folders[i].appIcons.removeAll { $0.id == app.id }
        }

        var appCopy = app
        appCopy.folderId = folderId
        appCopy.position = folders[folderIndex].appIcons.count
        folders[folderIndex].appIcons.append(appCopy)

        reindexPositions()
        rebuildGridItems()
        saveToPersistence()
    }

    func removeAppFromFolder(app: AppIcon, folderId: UUID) {
        guard let folderIndex = folders.firstIndex(where: { $0.id == folderId }) else { return }

        folders[folderIndex].appIcons.removeAll { $0.id == app.id }

        // Add back to root level
        var appCopy = app
        appCopy.folderId = nil
        appCopy.position = (gridItems.map { $0.position }.max() ?? 0) + 1
        apps.append(appCopy)

        // Auto-dissolve folder if ≤ 1 app
        if folders[folderIndex].appIcons.count <= 1 {
            dissolveFolder(at: folderIndex)
        }

        reindexPositions()
        rebuildGridItems()
        saveToPersistence()
    }

    func renameFolder(folderId: UUID, name: String) {
        guard let index = folders.firstIndex(where: { $0.id == folderId }) else { return }
        folders[index].name = name
        rebuildGridItems()
        saveToPersistence()
    }

    func deleteFolder(folderId: UUID) {
        guard let index = folders.firstIndex(where: { $0.id == folderId }) else { return }
        dissolveFolder(at: index)
        reindexPositions()
        rebuildGridItems()
        saveToPersistence()
    }

    private func dissolveFolder(at index: Int) {
        let folder = folders[index]
        let basePosition = folder.position

        // Move remaining apps back to root
        for (i, var app) in folder.appIcons.enumerated() {
            app.folderId = nil
            app.position = basePosition + i
            apps.append(app)
        }

        folders.remove(at: index)
    }

    func openFolder(folderId: UUID) {
        openFolderId = folderId
    }

    func closeFolder() {
        openFolderId = nil
    }

    func getOpenFolder() -> Folder? {
        guard let id = openFolderId else { return nil }
        return folders.first { $0.id == id }
    }

    func resetSearchSession() {
        searchText = ""
        isEditMode = false
        openFolderId = nil
        draggedIcon = nil
    }

    // MARK: - Drag & Drop

    func handleDrop(source: AppIcon, target: AppIcon) {
        if isEditMode {
            // Create folder from two apps
            createFolder(from: source, onto: target)
        } else {
            // Swap positions
            swapPositions(source: source, target: target)
        }
    }

    private func swapPositions(source: AppIcon, target: AppIcon) {
        guard let sourceIndex = apps.firstIndex(where: { $0.id == source.id }),
              let targetIndex = apps.firstIndex(where: { $0.id == target.id }) else { return }

        let tempPosition = apps[sourceIndex].position
        apps[sourceIndex].position = apps[targetIndex].position
        apps[targetIndex].position = tempPosition

        rebuildGridItems()
        saveToPersistence()
    }

    // MARK: - Position Management

    private func reindexPositions() {
        // Reindex root apps and folders by current order
        var allItems: [GridItem] = []
        allItems += apps.filter { $0.folderId == nil }.map { .app($0) }
        allItems += folders.map { .folder($0) }
        allItems.sort { $0.position < $1.position }

        for (i, item) in allItems.enumerated() {
            switch item {
            case .app(let icon):
                if let idx = apps.firstIndex(where: { $0.id == icon.id }) {
                    apps[idx].position = i
                }
            case .folder(let folder):
                if let idx = folders.firstIndex(where: { $0.id == folder.id }) {
                    folders[idx].position = i
                }
            }
        }

        // Reindex apps within each folder
        for fi in folders.indices {
            for ai in folders[fi].appIcons.indices {
                folders[fi].appIcons[ai].position = ai
            }
        }
    }

    // MARK: - Folder Naming

    private func suggestFolderName(for apps: [AppIcon]) -> String {
        for app in apps {
            let path = app.iconPath.lowercased()
            if path.contains("/utilities/") || path.contains("/实用工具/") {
                return "实用工具"
            }
            if path.contains("/system/applications") {
                return "其他"
            }
        }
        return "新建文件夹"
    }

    // MARK: - Persistence

    func saveToPersistence() {
        guard let context = modelContext else { return }

        // Save folders
        do {
            try context.delete(model: FolderEntity.self)
        } catch { }

        for folder in folders {
            let entity = FolderEntity(
                id: folder.id,
                name: folder.name,
                position: folder.position
            )
            context.insert(entity)

            // Save folder apps with folderId
            for app in folder.appIcons {
                saveAppEntity(app: app, folderId: folder.id, context: context)
            }
        }

        // Save root-level apps
        for app in apps where app.folderId == nil {
            saveAppEntity(app: app, folderId: nil, context: context)
        }

        try? context.save()
    }

    private func saveAppEntity(app: AppIcon, folderId: UUID?, context: ModelContext) {
        let predicate = #Predicate<AppIconEntity> { entity in
            entity.bundleIdentifier == app.bundleIdentifier
        }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let existing = try? context.fetch(descriptor).first {
            existing.position = app.position
            existing.folderId = folderId
            existing.name = app.name
            existing.iconPath = app.iconPath
        } else {
            let entity = AppIconEntity(
                bundleIdentifier: app.bundleIdentifier,
                name: app.name,
                iconPath: app.iconPath,
                position: app.position,
                folderId: folderId
            )
            context.insert(entity)
        }
    }

    func loadFromPersistence(context: ModelContext, scannedApps: [AppIcon]) {
        // Load saved folder data
        let folderDescriptor = FetchDescriptor<FolderEntity>(sortBy: [SortDescriptor(\.position)])
        let savedFolders = (try? context.fetch(folderDescriptor)) ?? []

        // Load saved app positions
        let appDescriptor = FetchDescriptor<AppIconEntity>()
        let savedAppEntities = (try? context.fetch(appDescriptor)) ?? []

        let savedAppMap = Dictionary(uniqueKeysWithValues: savedAppEntities.map { ($0.bundleIdentifier, $0) })

        // Build folders
        var loadedFolders: [Folder] = []
        for folderEntity in savedFolders {
            var folderApps: [AppIcon] = []
            for scannedApp in scannedApps {
                if let saved = savedAppMap[scannedApp.bundleIdentifier],
                   saved.folderId == folderEntity.id {
                    var app = scannedApp
                    app.folderId = folderEntity.id
                    app.position = saved.position
                    folderApps.append(app)
                }
            }
            folderApps.sort { $0.position < $1.position }

            if !folderApps.isEmpty {
                let folder = Folder(
                    id: folderEntity.id,
                    name: folderEntity.name,
                    position: folderEntity.position,
                    appIcons: folderApps
                )
                loadedFolders.append(folder)
            }
        }

        // Build root apps (not in any folder)
        let folderAppIds = Set(loadedFolders.flatMap { $0.appIcons.map { $0.bundleIdentifier } })
        var rootApps: [AppIcon] = []
        for scannedApp in scannedApps {
            if !folderAppIds.contains(scannedApp.bundleIdentifier) {
                var app = scannedApp
                if let saved = savedAppMap[app.bundleIdentifier] {
                    app.position = saved.position
                } else {
                    app.position = rootApps.count + loadedFolders.count
                }
                rootApps.append(app)
            }
        }
        rootApps.sort { $0.position < $1.position }

        self.apps = rootApps
        self.folders = loadedFolders
    }
}

// MARK: - String Extensions

extension String {
    func normalizedSearchText() -> String {
        folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: .current)
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .joined()
    }

    func transformToPinyin() -> String {
        let stringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(stringRef, nil, kCFStringTransformToLatin, false)
        CFStringTransform(stringRef, nil, kCFStringTransformStripDiacritics, false)
        return (stringRef as String).normalizedSearchText()
    }

    func transformToPinyinInitials() -> String {
        let stringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(stringRef, nil, kCFStringTransformToLatin, false)
        CFStringTransform(stringRef, nil, kCFStringTransformStripDiacritics, false)
        let pinyin = (stringRef as String)

        let initials = pinyin.components(separatedBy: " ").compactMap { $0.first }.map { String($0) }
        return initials.joined().normalizedSearchText()
    }
}
