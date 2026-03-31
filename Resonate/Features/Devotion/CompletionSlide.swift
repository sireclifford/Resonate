import SwiftUI

struct CompletionSlide: View {
    @ObservedObject var viewModel: DevotionViewModel
    let onNext: () -> Void
    let onOpenStory: () -> Void
    @State private var showsFinalCompletionSymbol = false
    @State private var isStoryChevronAnimating = false
    @State private var storyChevronOffset: CGFloat = -4
    @State private var storyChevronOpacity: Double = 0.55

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
                    .fixedSize(horizontal: false, vertical: true)
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
                            Image(systemName: "book.pages.fill")
                                .foregroundStyle(DevotionTheme.primaryText)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Read the Story Behind the Hymn")
                            .font(DevotionTheme.secondarySerifFont())
                            .foregroundStyle(DevotionTheme.primaryText)

                        Text("Open the background, meaning, and history of \"\(viewModel.title)\"")
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(DevotionTheme.secondaryText)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "arrow.right.circle.dotted")
                        .font(PremiumTheme.scaledIconFont(size: 24, weight: .semibold, relativeTo: .title3))
                        .foregroundStyle(DevotionTheme.secondaryText)
                        .opacity(storyChevronOpacity)
                        .offset(x: storyChevronOffset)
                        .animation(
                            isStoryChevronAnimating
                                ? .easeInOut(duration: 0.9).repeatForever(autoreverses: true)
                                : .default,
                            value: storyChevronOffset
                        )
                        .animation(
                            isStoryChevronAnimating
                                ? .easeInOut(duration: 0.9).repeatForever(autoreverses: true)
                                : .default,
                            value: storyChevronOpacity
                        )
                }
                .padding(18)
                .devotionPanel(cornerRadius: 24)
            }
            .buttonStyle(.plain)

            VStack(spacing: 10) {
                Text("“Peace I leave with you; my peace I give you. Do not be afraid”")
                    .font(DevotionTheme.secondarySerifFont())
                    .foregroundStyle(DevotionTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("JOHN 14:27")
                    .font(PremiumTheme.captionFont())
                    .tracking(1.8)
                    .foregroundStyle(DevotionTheme.secondaryText.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)

            Button(action: onNext) {
                Text("Amen")
                    .font(DevotionTheme.actionFont())
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 34)
                    .padding(.vertical, 16)
                    .background(DevotionTheme.accent)
                    .clipShape(Capsule())
            }

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .onAppear {
            isStoryChevronAnimating = true
            storyChevronOffset = 4
            storyChevronOpacity = 1
            if #available(iOS 26, *) {
                showsFinalCompletionSymbol = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showsFinalCompletionSymbol = true
                    }
                }
            } else {
                showsFinalCompletionSymbol = true
            }
        }
        .onDisappear {
            showsFinalCompletionSymbol = false
            isStoryChevronAnimating = false
            storyChevronOffset = -4
            storyChevronOpacity = 0.55
        }
    }
}
