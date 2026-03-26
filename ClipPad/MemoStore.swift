import Foundation
import Combine

/// メモ1枚分のデータ
struct MemoItem: Identifiable, Codable {
    let id: UUID
    var text: String
    let createdAt: Date

    init(text: String = "") {
        self.id = UUID()
        self.text = text
        self.createdAt = Date()
    }

    /// 一覧表示用プレビュー（1行目 or 「新規メモ」）
    var title: String {
        let first = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .newlines).first ?? ""
        if first.isEmpty { return "新規メモ" }
        return first.count > 30 ? String(first.prefix(30)) + "…" : first
    }
}

/// 複数メモの永続化ストア
final class MemoStore: ObservableObject {
    static let shared = MemoStore()

    @Published var memos: [MemoItem] = []

    private var saveTask: DispatchWorkItem?
    private let key = "clippad.memos"

    private init() {
        load()
        if memos.isEmpty {
            // 旧シングルメモからの移行
            if let old = UserDefaults.standard.string(forKey: "clippad.memo.text"), !old.isEmpty {
                memos = [MemoItem(text: old)]
                save()
                UserDefaults.standard.removeObject(forKey: "clippad.memo.text")
            } else {
                memos = [MemoItem()]
                save()
            }
        }
    }

    func addMemo() {
        memos.insert(MemoItem(), at: 0)
        save()
    }

    func updateText(id: UUID, text: String) {
        guard let idx = memos.firstIndex(where: { $0.id == id }) else { return }
        memos[idx].text = text
        scheduleSave()
    }

    func deleteMemo(_ memo: MemoItem) {
        memos.removeAll { $0.id == memo.id }
        if memos.isEmpty { memos = [MemoItem()] }
        save()
    }

    func deleteAll() {
        memos = [MemoItem()]
        save()
    }

    private func scheduleSave() {
        saveTask?.cancel()
        let task = DispatchWorkItem { [weak self] in self?.save() }
        saveTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(memos) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([MemoItem].self, from: data) else { return }
        memos = decoded
    }
}
