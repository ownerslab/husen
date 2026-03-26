import Foundation
import Combine

/// 付箋メモの永続化ストア
final class MemoStore: ObservableObject {
    static let shared = MemoStore()

    @Published var text: String {
        didSet { scheduleSave() }
    }

    private var saveTask: DispatchWorkItem?
    private let key = "clippad.memo.text"

    private init() {
        text = UserDefaults.standard.string(forKey: key) ?? ""
    }

    /// 入力のたびに即保存せず 0.3 秒デバウンス
    private func scheduleSave() {
        saveTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            guard let self else { return }
            UserDefaults.standard.set(self.text, forKey: self.key)
        }
        saveTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }
}
