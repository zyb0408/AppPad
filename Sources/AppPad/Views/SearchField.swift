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
        
        // Enable text editing and selection
        textField.isEditable = true
        textField.isSelectable = true

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
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            AppKitTextField.isAnyTextFieldEditing = true
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            AppKitTextField.isAnyTextFieldEditing = false
        }
    }
    
    // Global state to track if any text field is being edited
    static var isAnyTextFieldEditing = false
}

// MARK: - Search Bar View (SwiftUI Native)

struct SearchBarView: View {
    @Binding var text: String
    var onSubmit: (() -> Void)? = nil
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))

            TextField("搜索", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .focused($isFocused)
                .frame(height: 20)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    isFocused = true
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
        .onAppear {
            // Auto-focus when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = true
            }
        }
    }
    
    // Static methods for compatibility (now control FocusState)
    static var _focusBinding: Binding<Bool>?
    
    static func focusSearchField() {
        DispatchQueue.main.async {
            _focusBinding?.wrappedValue = true
        }
    }
    
    static var isSearchFieldFocused: Bool {
        _focusBinding?.wrappedValue ?? false
    }
}
