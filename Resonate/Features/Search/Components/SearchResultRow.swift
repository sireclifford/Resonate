import SwiftUI

struct SearchResultRow: View {
    let result: SearchResult
    let highlightedSnippet: AttributedString
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("#\(result.hymn.id)")
                .font(PremiumTheme.badgeFont())
                .foregroundStyle(.white.opacity(0.96))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    PremiumTheme.accent(for: colorScheme),
                                    PremiumTheme.accent(for: colorScheme).opacity(0.72)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(result.hymn.title)
                    .font(PremiumTheme.cardTitleFont())
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                    .lineLimit(1)

                Text(highlightedSnippet)
                    .font(PremiumTheme.captionFont())
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(PremiumTheme.badgeFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                .padding(8)
                .background(
                    Circle()
                        .fill(PremiumTheme.subtleFill(for: colorScheme))
                )
                .overlay(
                    Circle()
                        .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PremiumTheme.panelFill(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
        )
    }
}
