import AppKit

/// 純正 Stickies 風：枠なしでフォーカスを奪わない NSPanel
/// クリック時だけ一瞬キーウィンドウになり、クリック処理後すぐに手放す
final class BorderlessPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    /// 最初のクリックでも即座に反応する
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func sendEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            makeKey()
            super.sendEvent(event)
        case .leftMouseUp:
            super.sendEvent(event)
            // クリック処理後、キーを手放す
            DispatchQueue.main.async { [weak self] in
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
