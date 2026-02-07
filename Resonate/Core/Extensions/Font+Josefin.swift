import SwiftUI

extension Font {

    static func josefin(
        size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Font {

        let name: String

        switch weight {
        case .medium:
            name = "JosefinSans-Medium"
        case .semibold:
            name = "JosefinSans-SemiBold"
        default:
            name = "JosefinSans-Regular"
        }

        return .custom(name, size: size)
    }
}
