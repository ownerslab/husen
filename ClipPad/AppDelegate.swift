import AppKit
import SwiftUI

/// 常に最前面（F-01）・純正 Stickies 風枠なしウィンドウ
/// nonactivatingPanel で他アプリのフォーカスを奪わない
final class AppDelegate: NSObject, NSApplicationDelegate {
    static weak var panel: BorderlessPanel?
    private var mainWindow: BorderlessPanel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        createMainWindow()
        requestAccessibilityIfNeeded()
        // SwiftUI Settings の空ウィンドウを閉じる
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for window in NSApp.windows where window !== self.mainWindow {
                window.close()
            }
        }
    }

    private func createMainWindow() {
        let content = ContentView()
            .frame(minWidth: 140, minHeight: 80)
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
        panel.minSize = NSSize(width: 140, height: 80)
        panel.orderFront(nil)
        mainWindow = panel
        AppDelegate.panel = panel
    }

    private func requestAccessibilityIfNeeded() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let window = mainWindow {
            if window.isMiniaturized { window.deminiaturize(nil) }
            window.orderFront(nil)
        }
        return true
    }
}
