import SwiftUI

struct SettingsSectionCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let icon: String
    let subtitle: String?
    let content: Content

    init(
        title: String,
        icon: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(PremiumTheme.subtleFill(for: colorScheme))
                        .frame(width: 38, height: 38)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                        )

                    Image(systemName: icon)
                        .foregroundStyle(PremiumTheme.accent(for: colorScheme))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(PremiumTheme.scaledSystem(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

                    if let subtitle {
                        Text(subtitle)
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    }
                }
            }

            content
        }
        .padding(18)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 24)
    }
}
