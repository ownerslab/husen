import SwiftUI
import AppKit

extension Notification.Name {
    static let wordEditRequest = Notification.Name("wordEditRequest")
}

/// 単語登録（辞書）タブ：語句の一覧管理
struct WordView: View {
    @ObservedObject private var store = WordStore.shared
    @ObservedObject private var theme = ThemeStore.shared
    @State private var selectedId: WordItem.ID?
    @State private var editingId: WordItem.ID?
    @FocusState private var focusedId: UUID?

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
            List {
                ForEach(Array(store.sortedWords.enumerated()), id: \.element.id) { index, word in
                    wordRow(word: word, index: index + 1)
                        .listRowBackground(selectedId == word.id ? Color.accentColor : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if editingId != nil {
                                // 編集中に別の行をクリック → 編集終了
                                editingId = nil
                                focusedId = nil
                            }
                            selectedId = word.id
                            pastePhrase(word)
                        }
                        .contextMenu {
                            Button("編集") {
                                selectedId = word.id
                                editingId = word.id
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    focusedId = word.id
                                }
                            }
                            Divider()
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
            .onReceive(NotificationCenter.default.publisher(for: .wordEditRequest)) { note in
                if let newId = note.object as? UUID {
                    selectedId = newId
                    editingId = newId
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        focusedId = newId
                    }
                }
            }
            .onKeyPress(.return) {
                if let editingId {
                    // 編集中にEnter → 編集確定
                    self.editingId = nil
                    focusedId = nil
                    return .handled
                }
                if let selectedId {
                    // 選択中にEnter → 編集モードに入る
                    editingId = selectedId
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        focusedId = selectedId
                    }
                    return .handled
                }
                return .ignored
            }
        }
    }

    // MARK: - 行表示

    private func wordRow(word: WordItem, index: Int) -> some View {
        let isSelected = selectedId == word.id
        let isEditing = editingId == word.id

        return HStack(spacing: 0) {
            Text("\(index)")
                .font(theme.rowFont)
                .foregroundColor(isSelected ? .white : theme.textTertiary)
                .frame(width: 28, alignment: .center)

            Divider()
                .frame(height: 16)
                .background(theme.dividerColor)

            if isEditing {
                TextField("語句を入力", text: Binding(
                    get: { word.phrase },
                    set: { store.updatePhrase(id: word.id, phrase: $0) }
                ))
                .font(theme.rowFont)
                .foregroundColor(isSelected ? .white : theme.rowTextColor)
                .textFieldStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
                .focused($focusedId, equals: word.id)
                .onSubmit {
                    editingId = nil
                    focusedId = nil
                }
            } else {
                Text(word.phrase.isEmpty ? " " : word.phrase)
                    .font(theme.rowFont)
                    .foregroundColor(isSelected ? .white : theme.rowTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - アクション

    private func pastePhrase(_ word: WordItem) {
        guard !word.phrase.isEmpty else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(word.phrase, forType: .string)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            simulatePaste()
        }
    }

    private func copyPhrase(_ word: WordItem) {
        guard !word.phrase.isEmpty else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(word.phrase, forType: .string)
    }

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
