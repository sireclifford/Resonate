import SwiftUI

struct ReaderTopBar: View {

    let hymn: Hymn
    let availableLanguages: [Language]
    let selectedLanguage: Language
    let onLanguageSelect: (Language) -> Void

    let fontSize: ReaderFontSize
    let onFontSelect: (ReaderFontSize) -> Void

    let isFavourite: Bool
    let onFavouriteToggle: () -> Void

    var body: some View {
        HStack(spacing: 16) {

            Text("Hymns \(hymn.id) • \(hymn.verses.count) Verses")
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
                    Button(size.label) {
                        onFontSelect(size)
                    }
                }
            } label: {
                Text(fontSize.label)
                    .font(.josefin(size: 14))
            }

            Button(action: onFavouriteToggle) {
                Image(systemName: isFavourite ? "heart.fill" : "heart")
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
