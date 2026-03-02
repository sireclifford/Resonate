enum ChorusLabelStyle: String, CaseIterable, Identifiable {
    case chorus
    case refrain
    case hide

    var id: Self { self }

    var label: String {
        switch self {
        case .chorus: return "Chorus"
        case .refrain: return "Refrain"
        case .hide: return "Hide"
        }
    }
}
