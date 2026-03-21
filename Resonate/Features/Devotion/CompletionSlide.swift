import SwiftUI

struct CompletionSlide: View {
    @ObservedObject var viewModel: DevotionViewModel
    let onNext: () -> Void
    let onOpenStory: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 120)

            VStack(spacing: 18) {
                Image(systemName: "checkmark.seal.fill")
                    .font(PremiumTheme.scaledIconFont(size: 68, weight: .bold, relativeTo: .largeTitle))
                    .foregroundStyle(DevotionTheme.accent)

                Text("Worship Complete")
                    .font(DevotionTheme.panelTitleFont())
                    .foregroundStyle(DevotionTheme.primaryText)

                Text("You spent a moment with\n“\(viewModel.title)” today.")
                    .font(DevotionTheme.bodyFont())
                    .foregroundStyle(DevotionTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 34)
            .frame(maxWidth: .infinity)
            .devotionPanel(cornerRadius: 32)

            Button(action: onOpenStory) {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(DevotionTheme.chromeFill)
                        .frame(width: 54, height: 54)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(DevotionTheme.chromeBorder, lineWidth: 1)
                        )
                        .overlay(
                            Image(systemName: "book.pages")
                                .foregroundStyle(DevotionTheme.primaryText)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Story Behind the Hymn")
                            .font(DevotionTheme.secondarySerifFont())
                            .foregroundStyle(DevotionTheme.primaryText)

                        Text("Discover how \"\(viewModel.title)\" was written")
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(DevotionTheme.secondaryText)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(DevotionTheme.badgeFont())
                        .foregroundStyle(DevotionTheme.secondaryText)
                }
                .padding(18)
                .devotionPanel(cornerRadius: 24)
            }
            .buttonStyle(.plain)

            Button(action: onNext) {
                Text("Continue")
                    .font(DevotionTheme.actionFont())
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(DevotionTheme.accent)
                    .clipShape(Capsule())
            }

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
}
