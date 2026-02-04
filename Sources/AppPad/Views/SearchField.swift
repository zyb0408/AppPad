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
        
        // Store reference in coordinator
        context.coordinator.searchField = searchField
        
        return searchField
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        
        // Try to focus on first update
        if !context.coordinator.didAttemptFocus {
            context.coordinator.didAttemptFocus = true
            
            // Use multiple strategies to ensure focus
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let window = nsView.window {
                    window.makeFirstResponder(nsView)
                    
                    // Also try to activate the window
                    window.makeKeyAndOrderFront(nil)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        @Binding var text: String
        var didAttemptFocus = false
        weak var searchField: NSSearchField?
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSSearchField else { return }
            self.text = field.stringValue
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            // User started editing
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            // User finished editing
        }
    }
}
