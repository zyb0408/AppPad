import SwiftUI

struct SettingsView: View {
    @AppStorage("iconSize") private var iconSize: Double = 80.0
    @AppStorage("gridColumns") private var gridColumns: Int = 7
    @AppStorage("gridRows") private var gridRows: Int = 5
    
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Slider(value: $iconSize, in: 40...120, step: 4) {
                    Text("Icon Size")
                }
                Text("Current Size: \(Int(iconSize))px")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Layout")) {
                Stepper("Columns: \(gridColumns)", value: $gridColumns, in: 4...12)
                Stepper("Rows: \(gridRows)", value: $gridRows, in: 3...10)
            }
            
            Section(header: Text("About")) {
                Text("AppPad v0.1")
                Text("A macOS Launchpad alternative.")
                    .font(.caption)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}

#Preview {
    SettingsView()
}
