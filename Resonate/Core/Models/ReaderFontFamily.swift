import CoreFoundation
import SwiftUI

enum ReaderFontFamily: String, CaseIterable, Identifiable {
    case system
    case serif
    case josefin
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .system: return "System"
        case .serif: return "Serif"
        case .josefin: return "Josefin"
        }
    }
    
    func font(ofSize size: CGFloat) -> Font {
        switch self {
        case .system: return .system(size: size)
        case .serif: return .system(size: size, design: .serif)
        case .josefin: return .custom("JosefinSans-Regular", size: size)
        }
    }
}
