import SwiftUI
import AppKit

struct SearchField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeNSView(context: Context) -> NSSearchField {
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
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSSearchField else { return }
            self.text = field.stringValue
        }
    }
}
