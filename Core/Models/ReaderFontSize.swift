import CoreFoundation
enum ReaderFontSize: String, CaseIterable, Identifiable {
    case small
    case medium
    case large

    var id: Self { self }

    var label: String {
        switch self {
        case .small: return "16px"
        case .medium: return "18px"
        case .large: return "20px"
        }
    }

    var value: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 18
        case .large: return 20
        }
    }
}
