import SwiftUI
import AppKit

/// タブ種別
enum AppTab: String, CaseIterable {
    case clips = "履歴"
    case memo  = "メモ"
}

/// メインの一覧UI（要件 F-04, F-05, F-07 / 案A: 一覧形式）
struct ContentView: View {
    @StateObject private var store = ClipboardStore.shared
    @ObservedObject private var theme = ThemeStore.shared
    @State private var selectedId: ClipItem.ID?
    @State private var draggedId: ClipItem.ID?
    @State private var currentTab: AppTab = .clips
    @State private var isMinimized: Bool = false
    @State private var restoreSize: NSSize = NSSize(width: 300, height: 280)

    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack(spacing: 0) {
                headerIcon("xmark") {
                    AppDelegate.panel?.orderOut(nil)
                }
                headerIcon(isMinimized ? "arrow.up.left.and.arrow.down.right" : "minus") {
                    if let w = AppDelegate.panel {
                        if isMinimized {
                            w.setFrame(NSRect(origin: w.frame.origin, size: restoreSize), display: true, animate: true)
                            isMinimized = false
                        } else {
                            restoreSize = w.frame.size
                            w.setFrame(NSRect(origin: w.frame.origin, size: w.minSize), display: true, animate: true)
                            isMinimized = true
                        }
                    }
                }

                // タブ切替
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue)
                        .font(.system(size: 9, weight: currentTab == tab ? .bold : .regular))
                        .foregroundStyle(currentTab == tab ? theme.accentColor : theme.textTertiary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                        .onTapGesture { currentTab = tab }
                }

                Spacer()

                if currentTab == .clips {
                    headerIcon("plus") { store.copyFromFrontApp() }
                }
                if currentTab == .memo {
                    headerIcon("plus") { MemoStore.shared.addMemo() }
                }

                ThemePaletteButton(theme: theme)

                if currentTab == .clips {
                    headerIcon("trash") {
                        ClipboardStore.shared.clearAll()
                        selectedId = nil
                    }
                }
                if currentTab == .memo {
                    headerIcon("trash") { MemoStore.shared.deleteAll() }
                }
            }
            .padding(.horizontal, 2)
            .background(theme.headerBackground)

            Divider()
                .background(theme.dividerColor)

            // タブに応じたコンテンツ
            switch currentTab {
            case .clips:
                clipListView
            case .memo:
                MemoView()
            }
        }
        .background(theme.listBackground)
        .frame(minWidth: 140, minHeight: 80)
    }

    /// ヘッダー用アイコンボタン（onTapGesture で nonactivatingPanel でも確実動作）
    private func headerIcon(_ systemName: String, action: @escaping () -> Void) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 9, weight: .medium))
            .foregroundStyle(theme.headerIconColor)
            .frame(width: 28, height: 24)
            .contentShape(Rectangle())
            .onTapGesture { action() }
    }

    /// クリップ履歴一覧（左クリックで前面アプリにペースト / ドラッグで並べ替え）
    private var clipListView: some View {
        List(selection: $selectedId) {
            ForEach(store.items) { item in
                ClipRowView(item: item, isSelected: selectedId == item.id, theme: theme)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedId = item.id
                        store.pasteToFrontApp(item)
                    }
                    .onDrag {
                        draggedId = item.id
                        return NSItemProvider(object: item.id.uuidString as NSString)
                    }
                    .onDrop(of: [.text], delegate: ClipReorderDropDelegate(
                        overItemId: item.id,
                        draggedId: $draggedId,
                        store: store
                    ))
                    .contextMenu {
                        Button("クリップボードにコピーのみ") {
                            store.copyToPasteboard(item)
                        }
                        Button("前面アプリにペースト") {
                            store.pasteToFrontApp(item)
                        }
                        Divider()
                        Button("削除", role: .destructive) {
                            store.deleteItem(item)
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(theme.listBackground)
    }
}

private struct ClipReorderDropDelegate: DropDelegate {
    let overItemId: ClipItem.ID
    @Binding var draggedId: ClipItem.ID?
    let store: ClipboardStore

    func dropEntered(info: DropInfo) {
        guard let draggedId, draggedId != overItemId else { return }
        store.move(draggedId: draggedId, overId: overItemId)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedId = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

struct ClipRowView: View {
    let item: ClipItem
    let isSelected: Bool
    @ObservedObject var theme: ThemeStore

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.preview)
                .font(theme.rowFont)
                .lineLimit(2)
                .truncationMode(.tail)
                .foregroundColor(isSelected ? theme.accentColor : theme.rowTextColor)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// NSMenu でポップアップするパレットボタン（Menu の borderlessButton スタイルが色を上書きする問題を回避）
private struct ThemePaletteButton: View {
    @ObservedObject var theme: ThemeStore

    var body: some View {
        Image(systemName: "paintpalette")
            .font(.system(size: 9, weight: .medium))
            .foregroundStyle(theme.headerIconColor)
            .frame(width: 28, height: 24)
            .contentShape(Rectangle())
            .onTapGesture { showMenu() }
    }

    private func showMenu() {
        let menu = NSMenu()
        for t in ThemeStore.Theme.allCases {
            let item = NSMenuItem(title: t.displayName, action: #selector(ThemeMenuTarget.select(_:)), keyEquivalent: "")
            item.representedObject = t.rawValue
            item.target = ThemeMenuTarget.shared
            menu.addItem(item)
        }
        if let event = NSApp.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: NSApp.keyWindow?.contentView ?? NSView())
        }
    }
}

private class ThemeMenuTarget: NSObject {
    static let shared = ThemeMenuTarget()
    @objc func select(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let t = ThemeStore.Theme(rawValue: raw) else { return }
        ThemeStore.shared.current = t
    }
}

// Preview は Xcode 環境でのみ利用可能
// #Preview {
//     ContentView()
//         .frame(width: 320, height: 400)
// }
