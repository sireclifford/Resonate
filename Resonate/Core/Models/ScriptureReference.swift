import Foundation

struct ScriptureReference: Codable, Hashable {
    let bookUSFM: String
    let chapter: Int
    let verseStart: Int
    let verseEnd: Int?
}

extension ScriptureReference {
    
    var displayName: String {
        
        let bookName = USFMBookMapper.displayName(for: bookUSFM)
        
        if let end = verseEnd {
            return "\(bookName) \(chapter):\(verseStart)–\(end)"
        } else {
            return "\(bookName) \(chapter):\(verseStart)"
        }
    }
}
