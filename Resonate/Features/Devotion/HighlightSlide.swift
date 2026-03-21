import SwiftUI

struct HighlightSlide: View {
    let hymn: HymnIndex
    let highlight: String

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 120)

            VStack(spacing: 22) {
                Text("Hold onto this line")
                    .font(DevotionTheme.eyebrowFont())
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .foregroundStyle(DevotionTheme.accent)

                Text(highlight)
                    .font(DevotionTheme.highlightFont())
                    .foregroundStyle(DevotionTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                Text("— \(hymn.title)")
                    .font(DevotionTheme.secondarySerifFont())
                    .foregroundStyle(DevotionTheme.secondaryText)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 34)
            .frame(maxWidth: .infinity)
            .devotionPanel(cornerRadius: 32)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}
