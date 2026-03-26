import AppKit
import SwiftUI

/// 常に最前面（F-01）・純正 Stickies 風枠なしウィンドウ
/// nonactivatingPanel で他アプリのフォーカスを奪わない
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var mainWindow: BorderlessPanel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        createMainWindow()
        requestAccessibilityIfNeeded()
    }

    private func createMainWindow() {
        let content = ContentView()
            .frame(minWidth: 280, minHeight: 200)
        let hosting = NSHostingView(rootView: content)

        let panel = BorderlessPanel(
            contentRect: NSRect(x: 100, y: 400, width: 300, height: 280),
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )
        hosting.autoresizingMask = [.width, .height]
        panel.contentView = hosting
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isRestorable = false
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .windowBackgroundColor
        panel.hasShadow = true
        panel.isOpaque = true
        panel.minSize = NSSize(width: 280, height: 200)
        // フローティングパネルとして表示（フォーカスは奪わない）
        panel.orderFront(nil)
        mainWindow = panel
    }

    /// アクセシビリティ権限の確認・リクエスト（CGEvent送信に必要）
    private func requestAccessibilityIfNeeded() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let window = mainWindow {
            if window.isMiniaturized { window.deminiaturize(nil) }
            window.orderFront(nil)
        }
        return true
    }
}
