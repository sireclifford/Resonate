enum Language: String, Codable, CaseIterable, Identifiable {
    case english = "en"
    case french = "fr"
    case spanish = "es"
    case twi = "twi"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .french: return "French"
        case .spanish: return "Spanish"
        case .twi: return "Twi"
        }
    }
}
