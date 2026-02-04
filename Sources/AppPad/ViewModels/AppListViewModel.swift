import SwiftUI
import Combine

@MainActor
class AppListViewModel: ObservableObject {
    @Published var apps: [AppIcon] = []
    @Published var filteredApps: [AppIcon] = []
    @Published var isLoading = false
    @Published var searchText = ""
    
    private let scanner = AppScanner()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.filterApps(text)
            }
            .store(in: &cancellables)
    }
    
    private func filterApps(_ text: String) {
        guard !text.isEmpty else {
            filteredApps = apps
            return
        }
        
        let lowerText = text.lowercased()
        
        filteredApps = apps.filter { app in
            // 1. Direct match
            if app.name.lowercased().contains(lowerText) {
                return true
            }
            
            // 2. Pinyin match (Simple)
            let pinyin = app.name.transformToPinyin()
            if pinyin.contains(lowerText) {
                return true
            }
            
            // 3. Pinyin Initials (Acronyms) e.g. "wx" -> "WeiXin"
            let initials = app.name.transformToPinyinInitials()
            if initials.contains(lowerText) {
                return true
            }
            
            return false
        }
    }
    
    func loadApps() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            let foundApps = await scanner.scanApplications()
            self.apps = foundApps
            self.filteredApps = foundApps
            self.isLoading = false
        }
    }
}

extension String {
    func transformToPinyin() -> String {
        let stringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(stringRef, nil, kCFStringTransformToLatin, false)
        CFStringTransform(stringRef, nil, kCFStringTransformStripDiacritics, false)
        return (stringRef as String).lowercased().replacingOccurrences(of: " ", with: "")
    }
    
    func transformToPinyinInitials() -> String {
        let stringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(stringRef, nil, kCFStringTransformToLatin, false)
        CFStringTransform(stringRef, nil, kCFStringTransformStripDiacritics, false)
        let pinyin = (stringRef as String)
        
        let initials = pinyin.components(separatedBy: " ").compactMap { $0.first }.map { String($0) }
        return initials.joined().lowercased()
    }
}
