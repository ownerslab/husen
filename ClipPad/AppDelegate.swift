import AppKit
import SwiftUI

/// 常に最前面（F-01）・純正 Stickies 風枠なしウィンドウ
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var mainWindow: BorderlessWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        createMainWindow()
    }

    private func createMainWindow() {
        let content = ContentView()
            .frame(minWidth: 280, minHeight: 200)
        let hosting = NSHostingView(rootView: content)

        let window = BorderlessWindow(
            contentRect: NSRect(x: 100, y: 400, width: 300, height: 280),
            styleMask: [.borderless, .resizable],
            backing: .buffered,
            defer: false
        )
        hosting.autoresizingMask = [.width, .height]
        window.contentView = hosting
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces]
        window.isRestorable = false
        window.isMovableByWindowBackground = true
        window.backgroundColor = .windowBackgroundColor
        window.hasShadow = true
        window.isOpaque = true
        window.minSize = NSSize(width: 280, height: 200)
        window.makeKeyAndOrderFront(nil)
        mainWindow = window
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let window = mainWindow {
            if window.isMiniaturized { window.deminiaturize(nil) }
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
        }
        return true
    }
}
