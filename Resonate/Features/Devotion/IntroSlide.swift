import SwiftUI
struct IntroSlide: View {
    @ObservedObject var viewModel: DevotionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer(minLength: 110)

            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hymn of the Day")
                        .font(DevotionTheme.eyebrowFont())
                        .textCase(.uppercase)
                        .tracking(1.2)
                        .foregroundStyle(DevotionTheme.accent)

                    Text("#\(viewModel.index?.id ?? viewModel.hymnID)")
                        .font(PremiumTheme.roundedNumberFont(size: 15, relativeTo: .headline))
                        .foregroundStyle(DevotionTheme.secondaryText)

                    Text(viewModel.title)
                        .font(DevotionTheme.heroTitleFont())
                        .foregroundStyle(DevotionTheme.primaryText)
                        .lineSpacing(6)
                }

                Text("Take a moment to move slowly through this hymn and let its words gather your attention.")
                    .font(DevotionTheme.bodyFont())
                    .foregroundStyle(DevotionTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    introPill(text: "\(max(viewModel.verseCount, 1)) verses", icon: "text.justify.left")
                    introPill(text: viewModel.index?.category.title ?? "Hymn", icon: "tag.fill")
                }
            }
            .padding(26)
            .devotionPanel(cornerRadius: 32)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 44)
    }

    private func introPill(text: String, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
            Text(text)
        }
        .font(DevotionTheme.badgeFont())
        .foregroundStyle(DevotionTheme.secondaryText)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(DevotionTheme.chromeFill)
        .overlay(
            Capsule()
                .stroke(DevotionTheme.chromeBorder, lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}
