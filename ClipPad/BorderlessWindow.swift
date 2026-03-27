import AppKit
import SwiftUI

/// 純正 Stickies 風：枠なしでフォーカスを奪わない NSPanel
/// クリック時だけ一瞬キーウィンドウになり、クリック処理後すぐに手放す
final class BorderlessPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func sendEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            makeKey()
            super.sendEvent(event)
        default:
            super.sendEvent(event)
        }
    }

    override var acceptsMouseMovedEvents: Bool {
        get { true }
        set { super.acceptsMouseMovedEvents = newValue }
    }
}

/// 最初のクリックで即座にイベントを受け付けるホスティングビュー
final class FirstMouseHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}
