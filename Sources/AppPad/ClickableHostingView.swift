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
        print("ClickableHostingView: mouseDown called!")
        
        let locationInWindow = event.locationInWindow
        let locationInView = convert(locationInWindow, from: nil)
        
        print("Click location in window: \(locationInWindow)")
        print("Click location in view: \(locationInView)")
        
        // Check if a search field or text field is currently focused
        if let firstResponder = window?.firstResponder {
            let responderType = String(describing: type(of: firstResponder))
            print("Current firstResponder: \(responderType)")
            
            if firstResponder is NSSearchField || 
               firstResponder is NSTextField ||
               firstResponder is NSText ||
               responderType.contains("SearchField") ||
               responderType.contains("TextField") {
                print("✅ Search field is focused - passing event to super")
                super.mouseDown(with: event)
                return
            }
        }
        
        // Perform hit test to find the actual target
        if let hitView = hitTest(locationInView) {
            let hitViewType = String(describing: type(of: hitView))
            print("Hit view type: \(hitViewType)")
            print("Hit view: \(hitView)")
            
            // Check if the hit view is interactive
            if isInteractiveView(hitView) {
                print("✅ Interactive view detected - passing event to super")
                super.mouseDown(with: event)
                return
            }
            
            // Check if we hit the hosting view itself (background)
            if hitView == self {
                print("✅ Background click detected (hitView == self)")
                onBackgroundClick?()
                return
            }
            
            // For other views, check if they are part of the content
            // If it's a SwiftUI view container, it might be background
            if hitViewType.contains("HostingView") || 
               hitViewType.contains("_NSView") ||
               hitViewType.contains("PlatformView") ||
               hitViewType.contains("ViewHost") ||
               hitViewType.contains("EventView") ||  // PageGestureView's EventView passes clicks through
               hitViewType.contains("PlatformViewRepresentable") {
                print("✅ Container view click - treating as background")
                onBackgroundClick?()
                return
            }
            
            print("⚠️ Unknown view type - passing to super")
        } else {
            print("✅ No hit view - background click")
            onBackgroundClick?()
            return
        }
        
        // Default: pass to super
        print("→ Passing to super")
        super.mouseDown(with: event)
    }
    
    private func isInteractiveView(_ view: NSView) -> Bool {
        // Direct check for AppKit controls
        if view is NSTextField {
            print("  → Found NSTextField")
            return true
        }
        if view is NSSearchField {
            print("  → Found NSSearchField")
            return true
        }
        if view is NSButton {
            print("  → Found NSButton")
            return true
        }
        if view is NSControl {
            print("  → Found NSControl")
            return true
        }
        if view is NSImageView {
            print("  → Found NSImageView (likely app icon)")
            return true
        }
        
        // Check class name for specific interactive views
        let className = String(describing: type(of: view))
        
        // Check if it's a SwiftUI view that might be clickable
        if className.contains("ImageView") ||
           className.contains("DisplayList") ||
           className.contains("CoreUI") {
            print("  → Found SwiftUI Image-like view: \(className)")
            return true
        }
        
        // Check if it's a button-like view (for app icons)
        if className.contains("Button") && !className.contains("EventView") {
            print("  → Found Button-like view: \(className)")
            return true
        }
        
        // Check if any parent is an interactive control
        var currentView: NSView? = view
        var depth = 0
        while let parent = currentView?.superview {
            depth += 1
            let parentClass = String(describing: type(of: parent))
            print("  → Checking parent \(depth): \(parentClass)")
            
            if parent is NSTextField || 
               parent is NSSearchField || 
               parent is NSButton ||
               parent is NSControl ||
               parent is NSImageView {
                print("  → Found interactive control in parent chain")
                return true
            }
            
            // Check for SwiftUI views in parent chain
            if parentClass.contains("ImageView") ||
               parentClass.contains("DisplayList") {
                print("  → Found SwiftUI interactive view in parent chain")
                return true
            }
            
            currentView = parent
            
            // Don't go beyond this hosting view
            if parent == self {
                print("  → Reached hosting view, stopping")
                break
            }
            
            // Safety limit
            if depth > 10 {
                print("  → Max depth reached, stopping")
                break
            }
        }
        
        print("  → Not an interactive view")
        return false
    }
}
