import AppKit
import SwiftUI

/// 常に最前面（F-01）・ウィンドウレベル設定
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let window = NSApplication.shared.windows.first else { return }
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces]
        window.isRestorable = false
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
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
