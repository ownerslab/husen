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

    var body: some View {
        VStack(spacing: 0) {
            // 純正 Stickies 風：極薄ヘッダー（枠なしなのでコンテンツ最大化）
            HStack(spacing: 4) {
                Button {
                    NSApplication.shared.keyWindow?.close()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("閉じる")

                // タブ切替
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button {
                        currentTab = tab
                    } label: {
                        Text(tab.rawValue)
                            .font(.system(size: 9, weight: currentTab == tab ? .bold : .regular))
                            .foregroundStyle(currentTab == tab ? theme.accentColor : theme.textTertiary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                if currentTab == .clips {
                    // 「＋」ボタン：前面アプリの選択テキストを取り込み（マウスだけコピー）
                    Button {
                        store.copyFromFrontApp()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 8, weight: .medium))
                    }
                    .buttonStyle(.borderless)
                    .help("選択テキストを取り込み (Cmd+Cを送信)")
                }

                Menu {
                    ForEach(ThemeStore.Theme.allCases, id: \.self) { t in
                        Button(t.displayName) { theme.current = t }
                    }
                } label: {
                    Image(systemName: "paintpalette")
                        .font(.system(size: 8))
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .help("テーマを変更")

                if currentTab == .clips {
                    Button {
                        ClipboardStore.shared.clearAll()
                        selectedId = nil
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 8))
                    }
                    .buttonStyle(.borderless)
                    .help("一括削除")
                }

                if currentTab == .memo {
                    Button {
                        MemoStore.shared.text = ""
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 8))
                    }
                    .buttonStyle(.borderless)
                    .help("メモをクリア")
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
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
        .frame(minWidth: 280, minHeight: 200)
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

// Preview は Xcode 環境でのみ利用可能
// #Preview {
//     ContentView()
//         .frame(width: 320, height: 400)
// }
