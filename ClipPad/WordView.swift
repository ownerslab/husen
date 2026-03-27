import SwiftUI
import AppKit

/// 単語登録（辞書）タブ：語句の一覧管理
struct WordView: View {
    @ObservedObject private var store = WordStore.shared
    @ObservedObject private var theme = ThemeStore.shared
    @State private var selectedId: WordItem.ID?

    var body: some View {
        VStack(spacing: 0) {
            // カラムヘッダー
            HStack(spacing: 0) {
                Text("NO")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
                    .frame(width: 28, alignment: .center)

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
            List(selection: $selectedId) {
                ForEach(Array(store.sortedWords.enumerated()), id: \.element.id) { index, word in
                    WordRowView(word: word, index: index + 1,
                                isSelected: selectedId == word.id, theme: theme)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedId = word.id
                            pastePhrase(word)
                        }
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

    // MARK: - アクション

    /// 変換語句をクリップボードにコピーして前面アプリにペースト
    private func pastePhrase(_ word: WordItem) {
        guard !word.phrase.isEmpty else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(word.phrase, forType: .string)
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

/// 辞書行（仮置の ClipRowView と同じ構造）
struct WordRowView: View {
    let word: WordItem
    let index: Int
    let isSelected: Bool
    @ObservedObject var theme: ThemeStore

    var body: some View {
        HStack(spacing: 0) {
            Text("\(index)")
                .font(theme.rowFont)
                .foregroundColor(isSelected ? theme.accentColor : theme.textTertiary)
                .frame(width: 28, alignment: .center)

            Divider()
                .frame(height: 16)
                .background(theme.dividerColor)

            Text(word.phrase.isEmpty ? " " : word.phrase)
                .font(theme.rowFont)
                .foregroundColor(isSelected ? theme.accentColor : theme.rowTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
        }
        .padding(.vertical, 4)
    }
}
