struct Hymn: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let verses: [[String]] //each verse = array of lines
    let chorus: [String]?
    let category: HymnCategory
    let language: Language
}
