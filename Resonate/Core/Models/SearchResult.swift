import Foundation

struct SearchResult: Identifiable, Hashable {
    let id = UUID()

    let hymn: Hymn
    let matchedText: String
    let verseIndex: Int?
    let lineIndex: Int?
}
