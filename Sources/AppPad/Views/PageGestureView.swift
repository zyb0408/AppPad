import SwiftUI
import AppKit

struct PageGestureView: NSViewRepresentable {
    var onSwipeLeft: () -> Void
    var onSwipeRight: () -> Void
    
    func makeNSView(context: Context) -> EventView {
        let view = EventView()
        view.onSwipeLeft = onSwipeLeft
        view.onSwipeRight = onSwipeRight
        return view
    }
    
    func updateNSView(_ nsView: EventView, context: Context) {
        nsView.onSwipeLeft = onSwipeLeft
        nsView.onSwipeRight = onSwipeRight
    }
    
    class EventView: NSView {
        var onSwipeLeft: (() -> Void)?
        var onSwipeRight: (() -> Void)?
        
        private var accumulatedDeltaX: CGFloat = 0
        
        override var acceptsFirstResponder: Bool { true }
        
        override func scrollWheel(with event: NSEvent) {
            // Check for phase to detect discrete gestures if possible,
            // but for smooth scroll wheel/trackpad, we accumulate delta.
            
            accumulatedDeltaX += event.scrollingDeltaX
            
            let threshold: CGFloat = 30.0
            
            if accumulatedDeltaX < -threshold {
                // Swipe Left (Content moves left, so finger moves right -> Previous Page? No, strictly:
                // Swipe Left usually means "Show content to the right", i.e. Next Page.
                // Standard macOS: Two finger swipe left -> Go Next.
                onSwipeRight?() // Next Page
                accumulatedDeltaX = 0
            } else if accumulatedDeltaX > threshold {
                // Swipe Right -> Previous Page
                onSwipeLeft?()
                accumulatedDeltaX = 0
            }
            
            // If dragging stops or changes direction significantly, reset
            if event.phase == .ended || event.phase == .cancelled {
                accumulatedDeltaX = 0
            }
        }
    }
}
