import AppKit
import SwiftUI

struct EvanJoIdlePettingTrackingView: NSViewRepresentable {
    let onPointerEntered: () -> Void
    let onPointerExited: () -> Void
    let onPointerInteraction: () -> Void
    let onPointerDragged: () -> Void
    let onPointerMoved: (CGFloat, TimeInterval) -> Void

    func makeNSView(context: Context) -> PettingTrackingNSView {
        let view = PettingTrackingNSView()
        update(view)
        return view
    }

    func updateNSView(_ nsView: PettingTrackingNSView, context: Context) {
        update(nsView)
    }

    private func update(_ view: PettingTrackingNSView) {
        view.onPointerEntered = onPointerEntered
        view.onPointerExited = onPointerExited
        view.onPointerInteraction = onPointerInteraction
        view.onPointerDragged = onPointerDragged
        view.onPointerMoved = onPointerMoved
    }
}

final class PettingTrackingNSView: NSView {
    var onPointerEntered: (() -> Void)?
    var onPointerExited: (() -> Void)?
    var onPointerInteraction: (() -> Void)?
    var onPointerDragged: (() -> Void)?
    var onPointerMoved: ((CGFloat, TimeInterval) -> Void)?

    private var trackingArea: NSTrackingArea?
    private var localEventMonitor: Any?

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    override func updateTrackingAreas() {
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }

        let trackingArea = NSTrackingArea(
            rect: .zero,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
        self.trackingArea = trackingArea
        super.updateTrackingAreas()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        if window == nil {
            removeLocalEventMonitor()
        } else {
            installLocalEventMonitor()
        }
    }

    override func mouseEntered(with event: NSEvent) {
        guard NSEvent.pressedMouseButtons == 0 else {
            onPointerInteraction?()
            return
        }
        onPointerEntered?()
    }

    override func mouseExited(with event: NSEvent) {
        onPointerExited?()
    }

    override func mouseMoved(with event: NSEvent) {
        guard NSEvent.pressedMouseButtons == 0 else {
            onPointerInteraction?()
            return
        }

        let point = convert(event.locationInWindow, from: nil)
        onPointerMoved?(point.x, event.timestamp)
    }

    deinit {
        removeLocalEventMonitor()
    }

    private func installLocalEventMonitor() {
        guard localEventMonitor == nil else { return }

        localEventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [
                .leftMouseDown,
                .rightMouseDown,
                .otherMouseDown,
                .leftMouseDragged,
                .rightMouseDragged,
                .otherMouseDragged
            ]
        ) { [weak self] event in
            guard let self, event.window === self.window else { return event }
            switch event.type {
            case .leftMouseDragged, .rightMouseDragged, .otherMouseDragged:
                self.onPointerDragged?()
            default:
                self.onPointerInteraction?()
            }
            return event
        }
    }

    private func removeLocalEventMonitor() {
        if let localEventMonitor {
            NSEvent.removeMonitor(localEventMonitor)
            self.localEventMonitor = nil
        }
    }
}
