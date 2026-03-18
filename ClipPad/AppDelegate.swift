import AppKit
import SwiftUI

/// 常に最前面（F-01）・ウィンドウレベル設定
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        // ウィンドウは SwiftUI が遅延生成するため、次のランループで設定
        DispatchQueue.main.async { [weak self] in
            self?.configureWindow()
        }
    }

    private func configureWindow() {
        guard let window = NSApplication.shared.windows.first else { return }
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces]
        window.isRestorable = false
        window.isMovableByWindowBackground = true
        // シルバーバーを消す：タイトルバー透過＋トラフィックライト非表示（自前の×で閉じる）
        window.styleMask.insert(.fullSizeContentView)
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .windowBackgroundColor
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let window = sender.windows.first {
            if window.isMiniaturized { window.deminiaturize(nil) }
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
        }
        return true
    }
}
