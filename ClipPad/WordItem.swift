import Foundation

/// 単語登録1件分のデータ（読み → 変換語句）
struct WordItem: Identifiable, Codable, Equatable {
    let id: UUID
    var reading: String      // 入力/読み
    var phrase: String       // 変換/語句

    init(id: UUID = UUID(), reading: String = "", phrase: String = "") {
        self.id = id
        self.reading = reading
        self.phrase = phrase
    }
}
