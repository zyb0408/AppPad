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
                let appURL = URL(fileURLWithPath: fullPath)
                guard let bundle = Bundle(path: fullPath),
                      let bundleId = bundle.bundleIdentifier else { continue }
                
                let info = bundle.infoDictionary
                let localizedInfo = bundle.localizedInfoDictionary
                let fileName = (item as NSString).deletingPathExtension
                let localizedFileName = fileManager.displayName(atPath: fullPath)
                let localizedResourceValues = try? appURL.resourceValues(forKeys: [.localizedNameKey])
                let localizedResourceName = localizedResourceValues?.localizedName
                let metadataItem = MDItemCreateWithURL(kCFAllocatorDefault, appURL as CFURL)
                let spotlightDisplayName = metadataItem.flatMap {
                    MDItemCopyAttribute($0, kMDItemDisplayName) as? String
                }
                let nameCandidates = [
                    spotlightDisplayName,
                    localizedResourceName,
                    localizedFileName,
                    localizedInfo?["CFBundleDisplayName"] as? String,
                    localizedInfo?["CFBundleName"] as? String,
                    info?["CFBundleDisplayName"] as? String,
                    info?["CFBundleName"] as? String,
                    fileName
                ]

                let displayName = nameCandidates
                    .compactMap(Self.trimmedName)
                    .first ?? fileName

                let searchAliases = Self.uniqueNames(from: [
                    spotlightDisplayName,
                    localizedResourceName,
                    localizedFileName,
                    localizedInfo?["CFBundleDisplayName"] as? String,
                    localizedInfo?["CFBundleName"] as? String,
                    info?["CFBundleDisplayName"] as? String,
                    info?["CFBundleName"] as? String,
                    fileName,
                    bundleId.components(separatedBy: ".").last
                ])
                
                let appIcon = AppIcon(
                    id: UUID(),
                    name: displayName,
                    searchAliases: searchAliases,
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

    private static func uniqueNames(from candidates: [String?]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []

        for candidate in candidates {
            guard let value = trimmedName(candidate) else { continue }
            let key = value.normalizedSearchText()
            guard !key.isEmpty, seen.insert(key).inserted else { continue }
            result.append(value)
        }

        return result
    }

    private static func trimmedName(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
