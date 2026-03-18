import AppKit
import SwiftUI

/// 常に最前面（F-01）・ウィンドウレベル設定
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let window = NSApplication.shared.windows.first else { return }

        // 常に最前面（他アプリより前面に表示）
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces]

        // 通常アプリとして Dock に表示する
        NSApp.setActivationPolicy(.regular)

        // 起動直後に前面へ
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    // Dock のアイコンをクリックしたときにウィンドウを前面に出す
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let window = sender.windows.first {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        return true
    }
}
