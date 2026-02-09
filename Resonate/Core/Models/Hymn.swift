import Foundation
struct Hymn: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let verses: [[String]] //each verse = array of lines
    let chorus: [String]?
    let category: HymnCategory
    let language: Language
    
    var tuneFileName: String {
        String(format: "%03d.mid", id)
    }
}
