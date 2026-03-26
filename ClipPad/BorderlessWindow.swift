import AppKit

/// 純正 Stickies 風：枠なしでフォーカスを奪わない NSPanel
/// クリック時だけ一瞬キーウィンドウになり、クリック処理後すぐに手放す
final class BorderlessPanel: NSPanel {
    private var allowKey = false

    override var canBecomeKey: Bool { allowKey }
    override var canBecomeMain: Bool { false }

    override func sendEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            // クリック時だけキーを許可して処理を通す
            allowKey = true
            makeKey()
            super.sendEvent(event)
        case .leftMouseUp:
            super.sendEvent(event)
            // クリック処理後、キーを手放す
            DispatchQueue.main.async { [weak self] in
                self?.allowKey = false
                self?.resignKey()
            }
        default:
            super.sendEvent(event)
        }
    }

    override var acceptsMouseMovedEvents: Bool {
        get { true }
        set { super.acceptsMouseMovedEvents = newValue }
    }
}
