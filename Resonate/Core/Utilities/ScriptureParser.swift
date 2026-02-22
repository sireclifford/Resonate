import Foundation
import YouVersionPlatform

struct ScriptureParser {
    
    static func parse(_ reference: String, versionId: Int) -> BibleReference? {
        
        // Example: "1 Thessalonians 4:16"
        
        let parts = reference.split(separator: " ")
        guard parts.count >= 2 else { return nil }
        
        let chapterVerse = parts.last!
        let bookName = parts.dropLast().joined(separator: " ")
        
        let cvParts = chapterVerse.split(separator: ":")
        guard cvParts.count == 2,
              let chapter = Int(cvParts[0]),
              let verse = Int(cvParts[1])
        else { return nil }
        
        guard let usfm = USFMBookMapper.usfmCode(for: bookName) else {
            return nil
        }
        
        return BibleReference(
            versionId: versionId,
            bookUSFM: usfm,
            chapter: chapter,
            verse: verse
        )
    }
}
