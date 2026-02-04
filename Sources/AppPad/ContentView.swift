import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppListViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Material background
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                // Content layer
                VStack(spacing: 0) {
                    // Search Bar - with larger clickable area and visible border
                    VStack {
                        Text("⬇️ 点击这里搜索 ⬇️")
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        SearchField(text: $viewModel.searchText, placeholder: "搜索应用")
                            .frame(width: 500, height: 40)
                    }
                    .frame(height: 140)  // Fixed height for search area
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.5))  // Blue background to make it obvious
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)  // White border
                            )
                    )
                    .padding(.horizontal, 100)
                    .padding(.top, 40)
                    
                    // Icon Grid - constrained to remaining space
                    IconGridView(viewModel: viewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 20)
                }
            }
        }
        .onAppear {
            viewModel.loadApps()
            
            // Add Esc key monitor
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 { // 53 is Esc
                    // Hide window with animation
                    Task { @MainActor in
                        if let window = NSApp.keyWindow {
                            WindowAnimationManager.shared.hideWindow(window)
                        }
                    }
                    return nil
                }
                return event
            }
        }
    }
}

#Preview {
    ContentView()
}
