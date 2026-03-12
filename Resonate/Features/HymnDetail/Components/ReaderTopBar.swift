import SwiftUI

struct ReaderTopBar: View {

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

            Text("Hymn \(index.id) • \(verseCount) Verses")
                .font(.josefin(size: 14))
                .foregroundColor(.secondary)

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
                        .fill(Color(.secondarySystemBackground))
                )
            }

            Button(action: onFavouriteToggle) {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
