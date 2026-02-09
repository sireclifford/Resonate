import Foundation

enum HymnCategory: String, Codable, CaseIterable, Identifiable {

    case adoration_and_praise
    case morning_worship
    case evening_worship
    case faithfulness
    case second_advent
    case christian_life
    case christian_home
    case sabbath
    case prayer
    case hope_and_comfort
    case eternal_life

    /// Fallback for hymns not classified in source data
    case uncategorized

    var id: String { rawValue }

    var title: String {
        switch self {
        case .adoration_and_praise:
            return "Adoration & Praise"
        case .morning_worship:
            return "Morning Worship"
        case .evening_worship:
            return "Evening Worship"
        case .faithfulness:
            return "Faithfulness of God"
        case .second_advent:
            return "Second Advent"
        case .christian_life:
            return "Christian Life"
        case .christian_home:
            return "Christian Home"
        case .sabbath:
            return "Sabbath"
        case .prayer:
            return "Prayer"
        case .hope_and_comfort:
            return "Hope & Comfort"
        case .eternal_life:
            return "Eternal Life"
        case .uncategorized:
            return "Uncategorized"
        }
    }
}
