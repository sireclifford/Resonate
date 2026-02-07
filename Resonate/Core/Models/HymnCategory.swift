import Foundation

enum HymnCategory: String, Codable, CaseIterable, Identifiable {
    case praise
    case worship
    case faith
    case prayer
    case sabbath
    case secondComing
    
    var id: String { rawValue }
    
    var title: String {
        rawValue.capitalized
    }
}
