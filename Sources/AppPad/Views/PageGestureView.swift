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
        private var isGestureActive = false
        
        override var acceptsFirstResponder: Bool { true }
        
        override func scrollWheel(with event: NSEvent) {
            // Reset on gesture begin
            if event.phase == .began {
                accumulatedDeltaX = 0
                hasTriggered = false
                isGestureActive = true
            }
            
            // Only process if gesture is active
            guard isGestureActive else { return }
            
            // Don't accumulate if already triggered
            guard !hasTriggered else {
                if event.phase == .ended || event.phase == .cancelled {
                    accumulatedDeltaX = 0
                    hasTriggered = false
                    isGestureActive = false
                }
                return
            }
            
            // Accumulate delta
            accumulatedDeltaX += event.scrollingDeltaX
            
            // Lower threshold for more responsive swipes
            let threshold: CGFloat = 30.0
            
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
                isGestureActive = false
            }
        }
    }
}
