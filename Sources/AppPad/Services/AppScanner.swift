import Foundation
import AppKit
import CoreServices

/// A service to scan for installed applications on macOS.
/// It uses NSMetadataQuery to perform a system-wide Spotlight search for applications.
actor AppScanner {
    
    /// Scans the system for applications asynchronously.
    /// - Returns: An array of `AppIcon` structs representing the found applications.
    func scanApplications() async -> [AppIcon] {
        var apps: [AppIcon] = []
        let fileManager = FileManager.default
        let searchPaths = ["/Applications", "/System/Applications", NSHomeDirectory() + "/Applications"]
        
        for path in searchPaths {
            guard let items = try? fileManager.contentsOfDirectory(atPath: path) else { continue }
            
            for item in items {
                guard item.hasSuffix(".app") else { continue }
                
                let fullPath = (path as NSString).appendingPathComponent(item)
                guard let bundle = Bundle(path: fullPath),
                      let bundleId = bundle.bundleIdentifier else { continue }
                
                // Get Display Name
                let info = bundle.infoDictionary
                let name = (info?["CFBundleDisplayName"] as? String) ??
                           (info?["CFBundleName"] as? String) ??
                           (item as NSString).deletingPathExtension
                
                let appIcon = AppIcon(
                    id: UUID(),
                    name: name,
                    bundleIdentifier: bundleId,
                    iconPath: fullPath,
                    position: apps.count,
                    folderId: nil
                )
                
                apps.append(appIcon)
            }
        }
        
        // Sort by name
        apps.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        
        return apps
    }
}
