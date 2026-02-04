import SwiftUI
import Combine

@MainActor
class AppListViewModel: ObservableObject {
    @Published var apps: [AppIcon] = []
    @Published var isLoading = false
    
    private let scanner = AppScanner()
    
    func loadApps() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            let foundApps = await scanner.scanApplications()
            self.apps = foundApps
            self.isLoading = false
        }
    }
}
