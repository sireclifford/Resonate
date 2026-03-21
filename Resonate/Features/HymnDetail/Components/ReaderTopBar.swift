import SwiftUI

struct ReaderTopBar: View {
    @Environment(\.colorScheme) private var colorScheme

    let index: HymnIndex
    let verseCount: Int
    let availableLanguages: [Language]
    let selectedLanguage: Language
    let onLanguageSelect: (Language) -> Void

    let fontSize: ReaderFontSize
    let onFontSelect: (ReaderFontSize) -> Void

    let isFavourite: Bool
    let onFavouriteToggle: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Text("Hymn \(index.id)")
                    .font(PremiumTheme.scaledSystem(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

                Text("•")
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme).opacity(0.55))

                Text("\(verseCount) verses")
                    .font(PremiumTheme.scaledSystem(size: 14, weight: .medium))
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
            }

            Spacer()

//            Menu {
//                ForEach(availableLanguages) { language in
//                    Button(language.displayName) {
//                        onLanguageSelect(language)
//                    }
//                }
//            } label: {
//                Text("\(selectedLanguage.displayName) ▼")
//                    .font(PremiumTheme.scaledSystem(size: 14, weight: .medium))
//            }

            Menu {
                ForEach(ReaderFontSize.allCases) { size in
                    Button {
                        onFontSelect(size)
                    } label: {
                        HStack {
                            Text(size.label.replacingOccurrences(of: "px", with: " pt"))
                            if size == fontSize {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text("Aa")
                        .font(PremiumTheme.scaledSystem(size: 15, weight: .semibold, design: .serif))

                    Text(fontSize.label.replacingOccurrences(of: "px", with: " pt"))
                        .font(PremiumTheme.captionFont())
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(PremiumTheme.subtleFill(for: colorScheme))
                )
                .overlay(
                    Capsule()
                        .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                )
            }

            Button(action: onFavouriteToggle) {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavourite ? .red : PremiumTheme.primaryText(for: colorScheme))
                    .frame(width: 34, height: 34)
                    .background(
                        Circle()
                            .fill(PremiumTheme.subtleFill(for: colorScheme))
                    )
                    .overlay(
                        Circle()
                            .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            PremiumTheme.panelFill(for: colorScheme).opacity(colorScheme == .dark ? 0.84 : 0.92)
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(PremiumTheme.border(for: colorScheme))
                .frame(height: 1)
        }
    }
}
