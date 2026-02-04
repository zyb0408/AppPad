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
        private var hasTriggered = false
        
        override var acceptsFirstResponder: Bool { true }
        
        override func scrollWheel(with event: NSEvent) {
            // Reset on gesture begin
            if event.phase == .began {
                accumulatedDeltaX = 0
                hasTriggered = false
            }
            
            // Don't accumulate if already triggered
            guard !hasTriggered else {
                if event.phase == .ended || event.phase == .cancelled {
                    accumulatedDeltaX = 0
                    hasTriggered = false
                }
                return
            }
            
            // Accumulate delta
            accumulatedDeltaX += event.scrollingDeltaX
            
            let threshold: CGFloat = 50.0 // Increased threshold for more deliberate swipes
            
            if accumulatedDeltaX < -threshold {
                // Swipe Left -> Next Page
                onSwipeRight?()
                hasTriggered = true
                accumulatedDeltaX = 0
            } else if accumulatedDeltaX > threshold {
                // Swipe Right -> Previous Page
                onSwipeLeft?()
                hasTriggered = true
                accumulatedDeltaX = 0
            }
            
            // Reset on gesture end
            if event.phase == .ended || event.phase == .cancelled {
                accumulatedDeltaX = 0
                hasTriggered = false
            }
        }
    }
}
