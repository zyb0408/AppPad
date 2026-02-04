import SwiftUI
import AppKit

struct SearchField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField()
        searchField.delegate = context.coordinator
        searchField.placeholderString = placeholder
        searchField.focusRingType = .none
        searchField.isBordered = false
        searchField.drawsBackground = false
        
        // Customize text color
        if let cell = searchField.cell as? NSSearchFieldCell {
            cell.textColor = .white
            cell.placeholderAttributedString = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: NSColor.white.withAlphaComponent(0.5)]
            )
        }
        
        // Make it accept first responder
        searchField.refusesFirstResponder = false
        
        return searchField
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        
        // Auto-focus when window becomes key
        if !context.coordinator.hasFocused {
            DispatchQueue.main.async {
                nsView.window?.makeFirstResponder(nsView)
                context.coordinator.hasFocused = true
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        @Binding var text: String
        var hasFocused = false
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSSearchField else { return }
            self.text = field.stringValue
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            hasFocused = true
        }
    }
}
