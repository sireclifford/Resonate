import Foundation

struct HymnMeta: Codable, Identifiable {
    let hymnID: Int
    var id: Int { hymnID }

    let author: String?
    let authorBirthDeath: String?
    let translator: String?
    let yearWritten: Int?

    let historicalContext: String?
    let theologicalTheme: String?

    let scriptureReferences: [ScriptureReference]?
    let music: HymnMusic?

    let liturgicalUse: [String]?
    let keywords: [String]?

    let source: HymnSource?
}
