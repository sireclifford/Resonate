import SwiftUI

struct ReflectionSlide: View {
    @ObservedObject var viewModel: DevotionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 110)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Reflection")
                        .font(DevotionTheme.eyebrowFont())
                        .textCase(.uppercase)
                        .tracking(1.2)
                        .foregroundStyle(DevotionTheme.accent)

                    Text(viewModel.detail?.reflection ?? "Take a moment and let these words settle in your heart today.")
                        .font(DevotionTheme.panelTitleFont())
                        .foregroundStyle(DevotionTheme.primaryText)
                        .lineSpacing(10)

                    if let scripture = viewModel.detail?.scriptureRef {
                        Text(scripture)
                            .font(DevotionTheme.secondarySerifFont())
                            .foregroundStyle(DevotionTheme.secondaryText)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Prayer")
                            .font(DevotionTheme.eyebrowFont())
                            .textCase(.uppercase)
                            .tracking(1.1)
                            .foregroundStyle(DevotionTheme.mutedText)

                        Text("Lord, help me live what I just sang. Amen.")
                            .font(DevotionTheme.prayerFont())
                            .foregroundStyle(DevotionTheme.primaryText.opacity(0.92))
                            .lineSpacing(6)
                    }
                    .padding(18)
                    .background(DevotionTheme.chromeFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(DevotionTheme.chromeBorder, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                    if let story = viewModel.detail?.storyHint {
                        Text(story)
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(DevotionTheme.mutedText)
                    }
                }
                .padding(26)
                .devotionPanel(cornerRadius: 32)
            }

            Spacer(minLength: 32)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}
