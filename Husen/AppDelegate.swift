import AppKit
import SwiftUI

/// 常に最前面（F-01）・ウィンドウレベル設定
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let window = NSApplication.shared.windows.first else { return }
        setupWindow(window)
        ensureWindowOnScreen(window)
        bringWindowToFront(window)
    }

    // Dock のアイコンをクリックしたときにウィンドウを前面に出す
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        guard let window = sender.windows.first else { return true }
        setupWindow(window)
        ensureWindowOnScreen(window)
        bringWindowToFront(window)
        return true
    }

    private func setupWindow(_ window: NSWindow) {
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces]
        // 位置を復元しない（画面外に復元されるのを防ぐ）
        window.isRestorable = false
        NSApp.setActivationPolicy(.regular)
    }

    /// ウィンドウが画面外ならメイン画面の見える位置に移動する
    private func ensureWindowOnScreen(_ window: NSWindow) {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }
        let visible = screen.visibleFrame
        var frame = window.frame

        // 現在のフレームがどの画面とも交差していなければ、メイン画面に置く
        let onAnyScreen = NSScreen.screens.contains { screen.frame.intersects(frame) }
        if !onAnyScreen || frame.isEmpty {
            let width = max(320, min(frame.width, visible.width * 0.8))
            let height = max(300, min(frame.height, visible.height * 0.6))
            frame.size = NSSize(width: width, height: height)
            frame.origin.x = visible.midX - frame.width / 2
            frame.origin.y = visible.midY - frame.height / 2
            window.setFrame(frame, display: true)
        }

        if window.isMiniaturized {
            window.deminiaturize(nil)
        }
    }

    private func bringWindowToFront(_ window: NSWindow) {
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}
