import SwiftUI

/// 付箋メモページ：自由にメモ書きできるテキストエリア
struct MemoView: View {
    @ObservedObject private var memo = MemoStore.shared
    @ObservedObject private var theme = ThemeStore.shared

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $memo.text)
                .font(theme.rowFont)
                .scrollContentBackground(.hidden)
                .background(theme.listBackground)
                .foregroundColor(theme.rowTextColor)
                .padding(4)

            // プレースホルダー
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
