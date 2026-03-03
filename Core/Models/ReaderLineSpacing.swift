import CoreFoundation
enum ReaderLineSpacing: String, CaseIterable, Identifiable {
    case compact
    case comfortable
    case spacious

    var id: Self { self }

    var label: String {
        switch self {
        case .compact: return "Compact"
        case .comfortable: return "Comfortable"
        case .spacious: return "Spacious"
        }
    }

    var value: CGFloat {
        switch self {
        case .compact: return 6
        case .comfortable: return 12
        case .spacious: return 20
        }
    }
}
