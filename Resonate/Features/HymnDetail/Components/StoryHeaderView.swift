import SwiftUI

struct StoryHeaderView: View {
    let story: HymnStory
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Behind the Hymn")
                .font(PremiumTheme.eyebrowFont())
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(PremiumTheme.accent(for: colorScheme))

            Text(story.title)
                .font(PremiumTheme.titleFont(size: 30))
                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                let authorText = [story.author, story.authorBirthDeath]
                    .compactMap { $0 }
                    .joined(separator: " ")

                if let year = story.yearWritten, !authorText.isEmpty {
                    Text("Written \(String(year)) • \(authorText)")
                } else if !authorText.isEmpty {
                    Text(authorText)
                }
            }
            .font(PremiumTheme.bodyFont())
            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))

            Text("Historical setting, theological meaning, scripture references, and musical details gathered into one reading view.")
                .font(PremiumTheme.scaledSystem(size: 15, weight: .medium))
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 28)
    }
}

struct StorySectionContainer<Content: View>: View {
    let title: String
    let content: Content
    @Environment(\.colorScheme) private var colorScheme

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(PremiumTheme.scaledSystem(size: 24, weight: .semibold, design: .serif))
                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

            content
        }
        .padding(20)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 24)
    }
}

struct StoryBodyText: View {
    let text: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(text)
            .font(PremiumTheme.scaledSystem(size: 17, weight: .medium))
            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
            .lineSpacing(6)
            .fixedSize(horizontal: false, vertical: true)
    }
}
