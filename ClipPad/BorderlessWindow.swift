import AppKit

/// 純正 Stickies 風：枠なしでキーウィンドウになれる NSWindow
final class BorderlessWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
