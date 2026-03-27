import SwiftUI
import AppKit

struct HotkeyRecorderView: NSViewRepresentable {
    @Binding var hotkey: AppHotkey
    let isEnabled: Bool
    let onRecord: (AppHotkey) -> Void

    func makeNSView(context: Context) -> HotkeyRecorderNSView {
        let view = HotkeyRecorderNSView()
        view.onRecord = onRecord
        return view
    }

    func updateNSView(_ nsView: HotkeyRecorderNSView, context: Context) {
        nsView.hotkey = hotkey
        nsView.isRecorderEnabled = isEnabled
    }
}

final class HotkeyRecorderNSView: NSView {
    var hotkey: AppHotkey = .default {
        didSet { needsDisplay = true }
    }

    var isRecorderEnabled: Bool = true {
        didSet {
            if !isRecorderEnabled {
                isRecording = false
                window?.makeFirstResponder(nil)
            }
            needsDisplay = true
        }
    }

    var onRecord: ((AppHotkey) -> Void)?

    private var trackingArea: NSTrackingArea?
    private var eventMonitor: Any?
    private var isHovered = false {
        didSet { needsDisplay = true }
    }
    private var isRecording = false {
        didSet {
            if isRecording {
                startMonitoringKeyboard()
            } else {
                stopMonitoringKeyboard()
            }
            needsDisplay = true
        }
    }

    override var acceptsFirstResponder: Bool { isRecorderEnabled }

    deinit {
        MainActor.assumeIsolated {
            stopMonitoringKeyboard()
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea {
            removeTrackingArea(trackingArea)
        }

        let newTrackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(newTrackingArea)
        trackingArea = newTrackingArea
    }

    override func mouseDown(with event: NSEvent) {
        guard isRecorderEnabled else { return }
        isRecording = true
    }

    override func resignFirstResponder() -> Bool {
        isRecording = false
        return true
    }

    override func keyDown(with event: NSEvent) {
        guard !handle(event: event) else {
            return
        }
        super.keyDown(with: event)
    }

    override func flagsChanged(with event: NSEvent) {
        _ = handle(event: event)
        super.flagsChanged(with: event)
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
    }

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: bounds, xRadius: 8, yRadius: 8)
        let fillColor: NSColor

        if !isRecorderEnabled {
            fillColor = .controlBackgroundColor.withAlphaComponent(0.55)
        } else if isRecording {
            fillColor = .selectedControlColor.withAlphaComponent(0.16)
        } else if isHovered {
            fillColor = .controlAccentColor.withAlphaComponent(0.08)
        } else {
            fillColor = .controlBackgroundColor
        }

        fillColor.setFill()
        path.fill()

        let strokeColor = isRecording ? NSColor.controlAccentColor : NSColor.separatorColor
        strokeColor.setStroke()
        path.lineWidth = isRecording ? 2 : 1
        path.stroke()

        let text = isRecording ? "按下新的组合键" : hotkey.displayParts.joined(separator: " + ")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: isRecorderEnabled ? NSColor.labelColor : NSColor.secondaryLabelColor
        ]

        let attributed = NSAttributedString(string: text, attributes: attributes)
        let textRect = NSRect(
            x: 12,
            y: (bounds.height - attributed.size().height) / 2,
            width: bounds.width - 24,
            height: attributed.size().height
        )
        attributed.draw(in: textRect)
    }

    private func startMonitoringKeyboard() {
        guard eventMonitor == nil else { return }

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self else { return event }
            return self.handle(event: event) ? nil : event
        }
    }

    private func stopMonitoringKeyboard() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }

    @discardableResult
    private func handle(event: NSEvent) -> Bool {
        guard isRecording, isRecorderEnabled else {
            return false
        }

        if event.type == .flagsChanged {
            needsDisplay = true
            return true
        }

        if event.type == .keyDown, event.keyCode == KeyCode.escape.rawValue {
            isRecording = false
            return true
        }

        guard event.type == .keyDown else {
            return false
        }

        guard let hotkey = AppHotkey.from(event: event) else {
            NSSound.beep()
            return true
        }

        onRecord?(hotkey)
        isRecording = false
        return true
    }
}
