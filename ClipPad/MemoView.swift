import SwiftUI

/// 複数メモ対応：一覧 ↔ 編集を切り替え
struct MemoView: View {
    @ObservedObject private var store = MemoStore.shared
    @ObservedObject private var theme = ThemeStore.shared
    @State private var editingId: MemoItem.ID?

    var body: some View {
        if let editingId, let idx = store.memos.firstIndex(where: { $0.id == editingId }) {
            // 編集画面
            memoEditor(memo: store.memos[idx])
        } else {
            // 一覧画面
            memoList
        }
    }

    // MARK: - メモ一覧

    private var memoList: some View {
        List {
            ForEach(store.memos) { memo in
                Button {
                    editingId = memo.id
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(memo.title)
                            .font(theme.rowFont)
                            .foregroundColor(theme.rowTextColor)
                            .lineLimit(1)
                        Text(memo.createdAt, style: .date)
                            .font(.system(size: 8))
                            .foregroundStyle(theme.textTertiary)
                    }
                    .padding(.vertical, 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button("削除", role: .destructive) {
                        store.deleteMemo(memo)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(theme.listBackground)
    }

    // MARK: - メモ編集

    private func memoEditor(memo: MemoItem) -> some View {
        VStack(spacing: 0) {
            // 戻るバー
            HStack(spacing: 4) {
                Button {
                    editingId = nil
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 8, weight: .medium))
                    Text("一覧")
                        .font(.system(size: 9))
                }
                .buttonStyle(.plain)
                .foregroundStyle(theme.accentColor)
                Spacer()
                Button {
                    store.deleteMemo(memo)
                    editingId = nil
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 8))
                        .foregroundStyle(theme.headerIconColor)
                }
                .buttonStyle(.plain)
                .help("このメモを削除")
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(theme.headerBackground)

            Divider().background(theme.dividerColor)

            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding(
                    get: { memo.text },
                    set: { store.updateText(id: memo.id, text: $0) }
                ))
                .font(theme.rowFont)
                .scrollContentBackground(.hidden)
                .background(theme.listBackground)
                .foregroundColor(theme.rowTextColor)
                .padding(4)

                if memo.text.isEmpty {
                    Text("ここに自由にメモ...")
                        .font(theme.rowFont)
                        .foregroundStyle(theme.textTertiary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 12)
                        .allowsHitTesting(false)
                }
            }
            .background(theme.listBackground)
        }
    }
}
