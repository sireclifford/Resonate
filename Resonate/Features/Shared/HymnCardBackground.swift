import SwiftUI

struct HymnCardBackground: View {
    let seed: Int
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(baseFill)
            .overlay(topGlow)
            .overlay(symbolOverlay, alignment: .topTrailing)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
            )
    }

    private var baseFill: LinearGradient {
        LinearGradient(
            colors: [
                PremiumTheme.searchFieldFill(for: colorScheme),
                tintColor.opacity(colorScheme == .dark ? 0.18 : 0.26),
                PremiumTheme.subtleFill(for: colorScheme)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var topGlow: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(colorScheme == .dark ? 0.08 : 0.16),
                        .clear
                    ],
                    center: .topLeading,
                    startRadius: 10,
                    endRadius: 160
                )
            )
            .blendMode(.softLight)
    }

    private var symbolOverlay: some View {
        Image(systemName: symbolName)
            .font(PremiumTheme.scaledSystem(size: 54, weight: .regular))
            .foregroundStyle(
                colorScheme == .dark
                    ? Color.white.opacity(0.06)
                    : tintColor.opacity(0.16)
            )
            .padding(18)
    }

    private var tintColor: Color {
        let palette = [
            Color(red: 0.70, green: 0.56, blue: 0.38),
            Color(red: 0.53, green: 0.61, blue: 0.43),
            Color(red: 0.55, green: 0.49, blue: 0.70),
            Color(red: 0.52, green: 0.66, blue: 0.70),
            Color(red: 0.68, green: 0.49, blue: 0.46),
            Color(red: 0.71, green: 0.61, blue: 0.38)
        ]
        return palette[abs(seed) % palette.count]
    }

    private var symbolName: String {
        let symbols = [
            "music.note",
            "sparkles",
            "hands.clap",
            "heart.text.square",
            "sunrise",
            "moon.stars"
        ]
        return symbols[abs(seed) % symbols.count]
    }
}
