import Foundation
import AppKit
import Combine

/// クリップボード履歴の保存・取得・並べ替え（要件 F-04, F-05, F-06, F-07）
final class ClipboardStore: ObservableObject {
    static let shared = ClipboardStore()

    @Published private(set) var items: [ClipItem] = []
    private let maxItems = 50
    private let pasteboard = NSPasteboard.general
    private var changeCount: Int = -1
    private var timer: Timer?

    private init() {
        load()
        startPolling()
    }

    deinit {
        timer?.invalidate()
    }

    /// クリップボードの変更をポーリングで検知し、テキストなら仮保存
    private func startPolling() {
        changeCount = pasteboard.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func checkPasteboard() {
        let current = pasteboard.changeCount
        guard current != changeCount else { return }
        changeCount = current

        guard let string = pasteboard.string(forType: .string), !string.isEmpty else { return }
        // 自分で「選択してクリップボードに戻す」した直後は重複追加しない（同一テキスト連続は1つに）
        if items.first?.text == string { return }
        addItem(text: string)
    }

    /// 手動で仮保存（コピー検知と別に「追加」ボタン用）
    func addItem(text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return }
        let newItem = ClipItem(text: t)
        items.insert(newItem, at: 0)
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
        save()
    }

    /// 項目をクリックしたときにクリップボードに書き戻す（要件 F-05）
    func copyToPasteboard(_ item: ClipItem) {
        pasteboard.clearContents()
        pasteboard.setString(item.text, forType: .string)
        changeCount = pasteboard.changeCount
    }

    /// 並び順を変更（要件 F-07）
    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        save()
    }

    /// ドラッグ&ドロップによる並び替え（macOS向け）
    func move(draggedId: ClipItem.ID, overId: ClipItem.ID) {
        guard draggedId != overId,
              let fromIndex = items.firstIndex(where: { $0.id == draggedId }),
              let toIndex = items.firstIndex(where: { $0.id == overId })
        else { return }

        var updated = items
        let moved = updated.remove(at: fromIndex)
        updated.insert(moved, at: toIndex)
        items = updated
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func deleteItem(_ item: ClipItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: "husen.clipboard.items")
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: "husen.clipboard.items"),
              let decoded = try? JSONDecoder().decode([ClipItem].self, from: data) else { return }
        items = decoded
    }
}
