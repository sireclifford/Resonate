import Foundation

struct ScriptureReference: Codable, Hashable, Identifiable {
    
    var id: String {
        "\(bookUSFM)-\(chapter)-\(verseStart)-\(verseEnd ?? verseStart)"
    }
    
    let bookUSFM: String
    let chapter: Int
    let verseStart: Int
    let verseEnd: Int?
}
