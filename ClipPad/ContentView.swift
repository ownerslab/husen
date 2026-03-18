import SwiftUI
import AppKit

/// メインの一覧UI（要件 F-04, F-05, F-07 / 案A: 一覧形式）
struct ContentView: View {
    @StateObject private var store = ClipboardStore.shared
    @ObservedObject private var theme = ThemeStore.shared
    @State private var selectedId: ClipItem.ID?
    @State private var draggedId: ClipItem.ID?

    var body: some View {
        VStack(spacing: 0) {
            // 統合ヘッダー: 極小高さ（トラフィックライト非表示のため上余白不要）
            HStack(spacing: 4) {
                Button {
                    NSApplication.shared.keyWindow?.close()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("閉じる")
                Text("ClipPad")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(theme.textSecondary)
                Text("仮置き場")
                    .font(.system(size: 9))
                    .foregroundStyle(theme.textTertiary)
                Spacer()
                Menu {
                    ForEach(ThemeStore.Theme.allCases, id: \.self) { t in
                        Button(t.displayName) { theme.current = t }
                    }
                } label: {
                    Image(systemName: "paintpalette")
                        .font(.system(size: 9))
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .help("テーマを変更")
                Button {
                    ClipboardStore.shared.clearAll()
                    selectedId = nil
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 9))
                }
                .buttonStyle(.borderless)
                .help("一括削除")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(theme.headerBackground)

            Divider()
                .background(theme.dividerColor)

            // 一覧（クリックでクリップボードに戻す / ドラッグで並べ替え）
            List(selection: $selectedId) {
                ForEach(store.items) { item in
                    ClipRowView(item: item, isSelected: selectedId == item.id, theme: theme)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedId = item.id
                            store.copyToPasteboard(item)
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
                            Button("クリップボードに戻す") {
                                store.copyToPasteboard(item)
                            }
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
        .background(theme.listBackground)
        .frame(minWidth: 280, minHeight: 200)
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

#Preview {
    ContentView()
        .frame(width: 320, height: 400)
}
