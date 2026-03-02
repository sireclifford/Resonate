import Foundation

//Heavy
struct HymnDetail: Identifiable, Codable, Hashable {
    let id: Int
    let verses: [[String]]
    let chorus: [String]?
    var tuneFileName: String {
        String(format: "%03d.mid", id)
    }
}

//Lightweight
struct HymnIndex: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let category: HymnCategory
    let language: Language
    let verseCount: Int
}
