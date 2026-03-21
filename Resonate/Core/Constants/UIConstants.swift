import SwiftUI
import UIKit

enum PremiumTheme {
    private static func preferredTextStyle(for size: CGFloat) -> UIFont.TextStyle {
        switch size {
        case 38...:
            return .largeTitle
        case 28..<38:
            return .title1
        case 24..<28:
            return .title2
        case 20..<24:
            return .title3
        case 17..<20:
            return .body
        case 15..<17:
            return .callout
        case 13..<15:
            return .caption1
        default:
            return .caption2
        }
    }

    private static func scaledFont(
        size: CGFloat,
        weight: UIFont.Weight = .regular,
        design: UIFontDescriptor.SystemDesign = .default,
        relativeTo textStyle: UIFont.TextStyle
    ) -> Font {
        let baseDescriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor
        let descriptor = baseDescriptor.withDesign(design) ?? baseDescriptor
        let baseFont = UIFont(descriptor: descriptor, size: size)
        let scaledFont = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: baseFont)
        return Font(scaledFont)
    }

    static func scaledSystem(
        size: CGFloat,
        weight: UIFont.Weight = .regular,
        design: UIFontDescriptor.SystemDesign = .default
    ) -> Font {
        scaledFont(size: size, weight: weight, design: design, relativeTo: preferredTextStyle(for: size))
    }

    static func backgroundGradient(for colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color(red: 0.09, green: 0.08, blue: 0.10),
                    Color(red: 0.13, green: 0.11, blue: 0.14),
                    Color(red: 0.10, green: 0.09, blue: 0.11)
                ]
                : [
                    Color(red: 0.98, green: 0.95, blue: 0.90),
                    Color(red: 0.95, green: 0.90, blue: 0.82),
                    Color(red: 0.97, green: 0.94, blue: 0.88)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func accent(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.90, green: 0.72, blue: 0.44)
            : Color(red: 0.58, green: 0.39, blue: 0.20)
    }

    static func primaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : Color(red: 0.17, green: 0.12, blue: 0.10)
    }

    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(0.72)
            : Color(red: 0.28, green: 0.22, blue: 0.18).opacity(0.72)
    }

    static func panelFill(for colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color.white.opacity(0.07),
                    Color.white.opacity(0.03)
                ]
                : [
                    Color(red: 0.99, green: 0.97, blue: 0.94),
                    Color(red: 0.94, green: 0.88, blue: 0.80)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func subtleFill(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(0.05)
            : Color(red: 0.97, green: 0.94, blue: 0.89).opacity(0.92)
    }

    static func searchFieldFill(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color(red: 0.98, green: 0.96, blue: 0.93)
    }

    static func tabBarFill(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.13, green: 0.11, blue: 0.14).opacity(0.96)
            : Color(red: 0.98, green: 0.95, blue: 0.90).opacity(0.98)
    }

    static func border(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(0.10)
            : Color(red: 0.79, green: 0.70, blue: 0.58).opacity(0.42)
    }

    static func shadow(for colorScheme: ColorScheme) -> Color {
        Color.black.opacity(colorScheme == .dark ? 0.20 : 0.07)
    }

    static func titleFont(size: CGFloat) -> Font {
        scaledFont(size: size, weight: .bold, design: .serif, relativeTo: .largeTitle)
    }

    static func sectionTitleFont() -> Font {
        scaledFont(size: 28, weight: .bold, design: .serif, relativeTo: .title2)
    }

    static func cardTitleFont() -> Font {
        scaledFont(size: 20, weight: .semibold, design: .serif, relativeTo: .title3)
    }

    static func featureTitleFont() -> Font {
        scaledFont(size: 26, weight: .bold, design: .serif, relativeTo: .title2)
    }

    static func readingTitleFont() -> Font {
        scaledFont(size: 34, weight: .bold, design: .serif, relativeTo: .largeTitle)
    }

    static func bodySerifFont() -> Font {
        scaledFont(size: 17, weight: .medium, design: .serif, relativeTo: .body)
    }

    static func secondarySerifFont() -> Font {
        scaledFont(size: 16, weight: .semibold, design: .serif, relativeTo: .headline)
    }

    static func bodyFont() -> Font {
        scaledFont(size: 17, weight: .medium, relativeTo: .body)
    }

    static func captionFont() -> Font {
        scaledFont(size: 13, weight: .semibold, relativeTo: .caption1)
    }

    static func metadataFont() -> Font {
        scaledFont(size: 12, weight: .medium, relativeTo: .caption1)
    }

    static func eyebrowFont() -> Font {
        scaledFont(size: 11, weight: .bold, relativeTo: .caption2)
    }

    static func badgeFont() -> Font {
        scaledFont(size: 11, weight: .semibold, relativeTo: .caption2)
    }

    static func roundedNumberFont(size: CGFloat, relativeTo textStyle: UIFont.TextStyle = .title3) -> Font {
        scaledFont(size: size, weight: .bold, design: .rounded, relativeTo: textStyle)
    }

    static func scaledIconFont(size: CGFloat, weight: UIFont.Weight = .regular, relativeTo textStyle: UIFont.TextStyle) -> Font {
        scaledFont(size: size, weight: weight, relativeTo: textStyle)
    }
}

struct PremiumScreenBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            PremiumTheme.backgroundGradient(for: colorScheme)
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    PremiumTheme.accent(for: colorScheme).opacity(colorScheme == .dark ? 0.14 : 0.12),
                    .clear
                ],
                center: .top,
                startRadius: 10,
                endRadius: 280
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.05 : 0.16),
                    .clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 420
            )
            .ignoresSafeArea()
        }
    }
}

struct PremiumPanelModifier: ViewModifier {
    let colorScheme: ColorScheme
    var cornerRadius: CGFloat = 30

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(PremiumTheme.panelFill(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
            )
            .shadow(color: PremiumTheme.shadow(for: colorScheme), radius: 18, y: 10)
    }
}

extension View {
    func premiumPanel(colorScheme: ColorScheme, cornerRadius: CGFloat = 30) -> some View {
        modifier(PremiumPanelModifier(colorScheme: colorScheme, cornerRadius: cornerRadius))
    }
}
