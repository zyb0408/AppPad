import SwiftUI
import AppKit

struct SearchField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String

    // Shared reference for direct focus from key event handler
    static weak var currentField: NSSearchField?

    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField()
        searchField.delegate = context.coordinator
        searchField.placeholderString = placeholder
        searchField.focusRingType = .none
        searchField.isBordered = true
        searchField.bezelStyle = .roundedBezel
        searchField.appearance = NSAppearance(named: .vibrantDark)

        if let cell = searchField.cell as? NSSearchFieldCell {
            cell.textColor = .white
            cell.placeholderAttributedString = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: NSColor.white.withAlphaComponent(0.6)]
            )
        }

        context.coordinator.searchField = searchField
        SearchField.currentField = searchField
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

    @MainActor
    class Coordinator: NSObject, NSSearchFieldDelegate {
        @Binding var text: String
        weak var searchField: NSSearchField?

        init(text: Binding<String>) {
            _text = text
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSSearchField else { return }
            self.text = field.stringValue
        }
    }

    /// Directly focus the search field (call from key event handler)
    @MainActor
    static func focus() {
        guard let field = currentField else { return }
        field.window?.makeFirstResponder(field)
    }

    /// Check if search field is currently first responder
    @MainActor
    static var isFocused: Bool {
        guard let field = currentField else { return false }
        return field.window?.firstResponder == field.currentEditor()
    }
}
