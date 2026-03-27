import SwiftUI
import AppKit

/// 単語登録（辞書）タブ：読み → 変換語句の一覧管理
struct WordView: View {
    @ObservedObject private var store = WordStore.shared
    @ObservedObject private var theme = ThemeStore.shared
    @State private var editingId: WordItem.ID?

    var body: some View {
        VStack(spacing: 0) {
            // カラムヘッダー
            HStack(spacing: 0) {
                Text("入力/読み")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)

                Divider()
                    .frame(height: 14)
                    .background(theme.dividerColor)

                Text("変換/語句")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
            }
            .padding(.vertical, 4)
            .background(theme.headerBackground)

            Divider().background(theme.dividerColor)

            // 単語リスト
            List {
                ForEach(store.sortedWords) { word in
                    wordRow(word: word)
                        .contextMenu {
                            Button("変換語句をペースト") {
                                pastePhrase(word)
                            }
                            Button("変換語句をコピー") {
                                copyPhrase(word)
                            }
                            Divider()
                            Button("削除", role: .destructive) {
                                store.deleteWord(word)
                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(theme.listBackground)
        }
    }

    // MARK: - 行表示

    private func wordRow(word: WordItem) -> some View {
        HStack(spacing: 0) {
            // 読みフィールド
            if editingId == word.id {
                TextField("読み", text: Binding(
                    get: { word.reading },
                    set: { store.updateReading(id: word.id, reading: $0) }
                ))
                .font(theme.rowFont)
                .foregroundColor(theme.rowTextColor)
                .textFieldStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(word.reading.isEmpty ? " " : word.reading)
                    .font(theme.rowFont)
                    .foregroundColor(theme.rowTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()
                .frame(height: 16)
                .background(theme.dividerColor)
                .padding(.horizontal, 4)

            // 変換語句フィールド
            if editingId == word.id {
                TextField("語句", text: Binding(
                    get: { word.phrase },
                    set: { store.updatePhrase(id: word.id, phrase: $0) }
                ))
                .font(theme.rowFont)
                .foregroundColor(theme.rowTextColor)
                .textFieldStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onSubmit {
                    editingId = nil
                }
            } else {
                Text(word.phrase.isEmpty ? " " : word.phrase)
                    .font(theme.rowFont)
                    .foregroundColor(theme.rowTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            editingId = word.id
        }
        .onTapGesture(count: 1) {
            if editingId == word.id {
                // 編集中なら何もしない
            } else {
                pastePhrase(word)
            }
        }
    }

    // MARK: - アクション

    /// 変換語句をクリップボードにコピーして前面アプリにペースト
    private func pastePhrase(_ word: WordItem) {
        guard !word.phrase.isEmpty else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(word.phrase, forType: .string)
        // Cmd+V を送信
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            simulatePaste()
        }
    }

    /// 変換語句をクリップボードにコピーのみ
    private func copyPhrase(_ word: WordItem) {
        guard !word.phrase.isEmpty else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(word.phrase, forType: .string)
    }

    /// Cmd+V を前面アプリに送信
    private func simulatePaste() {
        guard AXIsProcessTrusted() else { return }
        let src = CGEventSource(stateID: .hidSystemState)
        guard let keyDown = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false) else { return }
        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
