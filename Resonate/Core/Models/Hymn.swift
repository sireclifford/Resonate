import Foundation

//Heavy
struct HymnDetail: Identifiable, Codable, Hashable {
    let id: Int
    let verses: [[String]]
    let chorus: [String]?
    var tuneFileName: String {
        String(format: "%03d.mid", id)
    }
    var reflection: String? = nil
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
    case highlight(text: String)
    case reflection
    case complete
}
