import Foundation
import AppKit
import CoreServices

/// A service to scan for installed applications on macOS.
/// It uses NSMetadataQuery to perform a system-wide Spotlight search for applications.
actor AppScanner {
    
    /// Scans the system for applications asynchronously.
    /// - Returns: An array of `AppIcon` structs representing the found applications.
    func scanApplications() async -> [AppIcon] {
        return await withCheckedContinuation { continuation in
            let query = NSMetadataQuery()
            
            // Search for Application Bundles
            query.predicate = NSPredicate(format: "kMDItemContentTypeTree == 'com.apple.application-bundle'")
            
            // Search in standard application locations
            query.searchScopes = [
                "/Applications",
                "/System/Applications",
                NSMetadataQueryUserHomeScope // Includes ~/Applications
            ]
            
            // Observe the notification for when the query finishes
            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidFinishGathering,
                object: query,
                queue: .main
            ) { notification in
                query.stop()
                NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: query)
                
                var apps: [AppIcon] = []
                
                for item in query.results {
                    guard let metadataItem = item as? NSMetadataItem,
                          let path = metadataItem.value(forAttribute: NSMetadataItemPathKey) as? String,
                          let bundle = Bundle(path: path),
                          let bundleId = bundle.bundleIdentifier,
                          let info = bundle.infoDictionary else {
                        continue
                    }
                    
                    // Get Display Name
                    let name = (info["CFBundleDisplayName"] as? String) ??
                               (info["CFBundleName"] as? String) ??
                               (path as NSString).lastPathComponent.replacingOccurrences(of: ".app", with: "")
                    
                    // Filter out strict system agents/helpers if desired, but for now we keep mostly everything
                    // that looks like a legit app.
                    
                    let appIcon = AppIcon(
                        id: UUID(),
                        name: name,
                        bundleIdentifier: bundleId,
                        iconPath: path, // We store the path to the .app, we can derive the icon later
                        position: apps.count,
                        folderId: nil
                    )
                    
                    apps.append(appIcon)
                }
                
                // Sort by name
                apps.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
                
                continuation.resume(returning: apps)
            }
            
            query.start()
        }
    }
}
