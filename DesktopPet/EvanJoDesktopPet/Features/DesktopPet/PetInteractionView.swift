import AppKit

final class PetInteractionView: NSView {
    var onClick: (() -> Void)?
    var onDragBegan: (() -> Void)?
    var onDrag: ((NSPoint, NSPoint) -> Void)?
    var onDragEnded: ((NSPoint) -> Void)?

    private static let dragThreshold: CGFloat = 4

    private var mouseDownLocation: NSPoint?
    private var isDragging = false
    private var pointerOffsetFromWindowOrigin = NSPoint.zero

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        bounds.contains(point) ? self : nil
    }

    override func mouseDown(with event: NSEvent) {
        guard let window else {
            mouseDownLocation = nil
            return
        }

        let pointerLocation = NSEvent.mouseLocation
        mouseDownLocation = pointerLocation
        isDragging = false
        pointerOffsetFromWindowOrigin = NSPoint(
            x: pointerLocation.x - window.frame.minX,
            y: pointerLocation.y - window.frame.minY
        )
    }

    override func mouseDragged(with event: NSEvent) {
        let pointerLocation = NSEvent.mouseLocation
        guard let mouseDownLocation else { return }

        if !isDragging {
            let distance = hypot(
                pointerLocation.x - mouseDownLocation.x,
                pointerLocation.y - mouseDownLocation.y
            )
            guard distance >= Self.dragThreshold else { return }

            isDragging = true
            onDragBegan?()
        }

        let proposedOrigin = NSPoint(
            x: pointerLocation.x - pointerOffsetFromWindowOrigin.x,
            y: pointerLocation.y - pointerOffsetFromWindowOrigin.y
        )

        onDrag?(proposedOrigin, pointerLocation)
    }

    override func mouseUp(with event: NSEvent) {
        guard mouseDownLocation != nil else { return }

        let pointerLocation = NSEvent.mouseLocation
        let didDrag = isDragging
        mouseDownLocation = nil
        isDragging = false

        if didDrag {
            onDragEnded?(pointerLocation)
        } else {
            onClick?()
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        guard let menu else {
            super.rightMouseDown(with: event)
            return
        }

        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
}
