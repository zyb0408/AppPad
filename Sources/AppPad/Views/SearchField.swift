import SwiftUI
import AppKit

// MARK: - AppKit NSTextField for reliable text input in borderless windows

struct AppKitTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    var font: NSFont = .systemFont(ofSize: 15)
    var alignment: NSTextAlignment = .left
    var onCreated: ((NSTextField) -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.delegate = context.coordinator
        textField.stringValue = text
        textField.isBordered = false
        textField.drawsBackground = false
        textField.focusRingType = .none
        textField.font = font
        textField.textColor = .white
        textField.alignment = alignment
        textField.lineBreakMode = .byTruncatingTail
        textField.cell?.sendsActionOnEndEditing = false
        textField.appearance = NSAppearance(named: .vibrantDark)

        if !placeholder.isEmpty {
            textField.placeholderAttributedString = NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: NSColor.white.withAlphaComponent(0.5),
                    .font: font
                ]
            )
        }

        onCreated?(textField)
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: AppKitTextField

        init(_ parent: AppKitTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                parent.text = textField.stringValue
            }
        }
    }
}

// MARK: - Search Bar View

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))

            AppKitTextField(
                text: $text,
                placeholder: "搜索",
                onCreated: { field in
                    SearchBarView._searchField = field
                }
            )
            .frame(height: 20)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    SearchBarView.focusSearchField()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
        )
    }

    // MARK: - Static focus management

    static weak var _searchField: NSTextField?

    static func focusSearchField() {
        guard let field = _searchField else { return }
        DispatchQueue.main.async {
            field.window?.makeFirstResponder(field)
        }
    }

    static var isSearchFieldFocused: Bool {
        _searchField?.currentEditor() != nil
    }
}
