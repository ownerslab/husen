import AppKit

/// 純正 Stickies 風：枠なしでフォーカスを奪わない NSPanel
/// nonactivatingPanel により、クリックしても他アプリのフォーカスを奪わない
final class BorderlessPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    /// マウスイベントを受け取れるようにする（非キーウィンドウでも）
    override func sendEvent(_ event: NSEvent) {
        // 左クリック・右クリックを通常通り処理
        super.sendEvent(event)
    }

    override var acceptsMouseMovedEvents: Bool {
        get { true }
        set { super.acceptsMouseMovedEvents = newValue }
    }
}
