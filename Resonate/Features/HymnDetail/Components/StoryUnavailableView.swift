import SwiftUI

struct StoryUnavailableView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            PremiumScreenBackground()

            VStack(spacing: 18) {
                Image(systemName: "book.closed")
                    .font(PremiumTheme.scaledSystem(size: 38, weight: .semibold))
                    .foregroundStyle(PremiumTheme.accent(for: colorScheme))

                Text("Story Not Available")
                    .font(PremiumTheme.sectionTitleFont())
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

                Text("We are still adding historical and musical details for this hymn.")
                    .font(PremiumTheme.bodyFont())
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .premiumPanel(colorScheme: colorScheme, cornerRadius: 28)
            .padding(.horizontal, 20)
        }
    }
}
