import AppKit
import SwiftUI

class ClickableHostingView<Content: View>: NSHostingView<Content> {
    var onBackgroundClick: (() -> Void)?

    required init(rootView: Content) {
        super.init(rootView: rootView)
        setupEventHandling()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupEventHandling()
    }

    private func setupEventHandling() {
        self.wantsLayer = true
    }

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
    }
}
