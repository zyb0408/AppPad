import AppKit
import SwiftUI

/// Custom hosting view that handles background clicks
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
        // Ensure this view can receive mouse events
        self.wantsLayer = true
        print("ClickableHostingView: setupEventHandling called")
    }
    
    override var acceptsFirstResponder: Bool {
        print("ClickableHostingView: acceptsFirstResponder called")
        return true
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        print("ClickableHostingView: acceptsFirstMouse called")
        return true
    }
    
    override func mouseDown(with event: NSEvent) {
        // Always pass the event to super to let SwiftUI handle gestures (TapGesture)
        // We handle background clicks in SwiftUI (ContentView.swift) using .onTapGesture on the background layer
        super.mouseDown(with: event)
    }
}
