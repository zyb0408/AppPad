import SwiftUI
import AppKit

struct SearchField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeNSView(context: Context) -> NSSearchField {
        print("SearchField: makeNSView called")
        let searchField = NSSearchField()
        searchField.delegate = context.coordinator
        searchField.placeholderString = placeholder
        searchField.focusRingType = .default  // Show focus ring
        searchField.isBordered = true
        searchField.bezelStyle = .roundedBezel
        
        // Customize text color
        if let cell = searchField.cell as? NSSearchFieldCell {
            cell.textColor = .white
            cell.placeholderAttributedString = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: NSColor.white.withAlphaComponent(0.6)]
            )
        }
        
        print("SearchField: NSSearchField created - \(searchField)")
        return searchField
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
            print("SearchField.Coordinator: initialized")
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSSearchField else { return }
            print("SearchField: text changed to '\(field.stringValue)'")
            self.text = field.stringValue
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            print("SearchField: began editing")
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            print("SearchField: ended editing")
        }
    }
}
