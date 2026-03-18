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
                    .font(.josefin(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)

                Text("•")
                    .foregroundStyle(.tertiary)

                Text("\(verseCount) verses")
                    .font(.josefin(size: 14))
                    .foregroundStyle(.secondary)
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
//                    .font(.josefin(size: 14))
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
                        .font(.system(size: 15, weight: .semibold, design: .serif))

                    Text(fontSize.label.replacingOccurrences(of: "px", with: " pt"))
                        .font(.josefin(size: 13))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color(.secondarySystemBackground))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.05), lineWidth: 1)
                )
            }

            Button(action: onFavouriteToggle) {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavourite ? .red : .primary)
                    .frame(width: 34, height: 34)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color(.secondarySystemBackground))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.05), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            colorScheme == .dark ? Color.black.opacity(0.16) : Color.white.opacity(0.82)
        )
    }
}
