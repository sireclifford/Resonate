import Foundation

//Heavy
struct HymnDetail: Identifiable, Codable, Hashable {
    let id: Int
    let verses: [[String]]
    let chorus: [String]?
    let scriptureRef: String?
    let highlight: String?
    let storyHint: String?
    var tuneFileName: String {
        String(format: "%03d.mid", id)
    }
    let reflection: String?
}

//Lightweight
struct HymnIndex: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let category: HymnCategory
    let language: Language
    let verseCount: Int
}

enum WorshipSlide: Hashable {
    case intro
    case verse(verseIndex: Int)
    case chorus
    case highlight(text: String)
    case reflection
    case complete
}
