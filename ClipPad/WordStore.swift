import Foundation
import Combine

/// 単語登録の永続化ストア
final class WordStore: ObservableObject {
    static let shared = WordStore()

    @Published var words: [WordItem] = []

    private let key = "clippad.words"

    private init() {
        load()
    }

    /// 読みでソート済みの単語一覧
    var sortedWords: [WordItem] {
        words.sorted { $0.reading.localizedCompare($1.reading) == .orderedAscending }
    }

    func addWord(reading: String = "", phrase: String = "") {
        let word = WordItem(reading: reading, phrase: phrase)
        words.append(word)
        save()
    }

    func updateReading(id: UUID, reading: String) {
        guard let idx = words.firstIndex(where: { $0.id == id }) else { return }
        words[idx].reading = reading
        save()
    }

    func updatePhrase(id: UUID, phrase: String) {
        guard let idx = words.firstIndex(where: { $0.id == id }) else { return }
        words[idx].phrase = phrase
        save()
    }

    func deleteWord(_ word: WordItem) {
        words.removeAll { $0.id == word.id }
        save()
    }

    func deleteAll() {
        words.removeAll()
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(words) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([WordItem].self, from: data) else { return }
        words = decoded
    }
}
