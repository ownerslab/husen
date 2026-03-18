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
        window.isRestorable = false
        // 閉じるボタンを無効化＝ウィンドウを破棄しない。終了は ⌘Q または メニュー「Husen → 終了」
        window.styleMask = [.titled, .miniaturizable, .resizable]
        NSApp.setActivationPolicy(.regular)
    }

    /// ウィンドウが画面外ならメイン画面の見える位置に移動する
    private func ensureWindowOnScreen(_ window: NSWindow) {
        guard let mainScreen = NSScreen.main ?? NSScreen.screens.first else { return }
        let visible = mainScreen.visibleFrame
        var frame = window.frame

        // 現在のフレームがどの画面とも交差していなければ、メイン画面に置く
        let onAnyScreen = NSScreen.screens.contains { scr in scr.frame.intersects(frame) }
        if !onAnyScreen || frame.size.width < 100 || frame.size.height < 100 {
            let w = max(320.0, min(frame.size.width, visible.size.width * 0.8))
            let h = max(300.0, min(frame.size.height, visible.size.height * 0.6))
            let x = visible.midX - w / 2
            let y = visible.midY - h / 2
            window.setFrame(CGRect(x: x, y: y, width: w, height: h), display: true)
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
