import SwiftUI

struct CategoryDetailView: View {
    let category: HymnCategory
    let hymns: [HymnIndex]
    let environment: AppEnvironment
    @ObservedObject var favouritesService: FavouritesService
    @Environment(\.colorScheme) private var colorScheme

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            PremiumScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    hero

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Hymns in This Path")
                            .font(PremiumTheme.sectionTitleFont())
                            .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

                        Text("\(hymns.count) hymns gathered for \(category.title.lowercased()).")
                            .font(PremiumTheme.bodyFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    }
                    .padding(.horizontal, 20)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(hymns) { hymn in
                            NavigationLink(value: hymn) {
                                HymnCardView(
                                    index: hymn,
                                    isFavourite: favouritesService.isFavourite(id: hymn.id),
                                    onFavouriteToggle: {
                                        favouritesService.toggle(id: hymn.id)
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .padding(.top, 12)
            }
        }
        .navigationTitle(category.title)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .miniPlayerInset(using: environment)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: symbol(for: category))
                    .font(PremiumTheme.scaledSystem(size: 24, weight: .semibold))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

                Spacer()

                Text("\(hymns.count) hymns")
                    .font(PremiumTheme.captionFont())
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
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
                    .clipShape(Capsule())
            }

            Text(category.title)
                .font(PremiumTheme.titleFont(size: 30))
                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

            Text(devotionalDescriptor(for: category))
                .font(PremiumTheme.bodyFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 28)
        .padding(.horizontal, 20)
    }

    private func devotionalDescriptor(for category: HymnCategory) -> String {
        switch category {
        case .adoration_and_praise, .opening_of_worship, .glory_and_praise, .call_to_worship:
            return "Enter this path when your heart is reaching for reverence, praise, and gathered worship."
        case .meditation_and_prayer:
            return "A quieter path for stillness, surrender, and listening prayer."
        case .hope_and_comfort:
            return "These hymns hold space for grief, uncertainty, courage, and promise."
        case .morning_worship:
            return "A fitting beginning for the first moments of devotion in a new day."
        case .sda_hymnal_evening_worship:
            return "A closing collection for gratitude, rest, and evening peace."
        case .sabbath:
            return "Hymns gathered for Sabbath welcome, joy, and holy rest."
        case .second_advent:
            return "A collection shaped by longing, watchfulness, and the promise of Christ’s return."
        default:
            return "A curated devotional path through the hymnbook, shaped for worship and reflection."
        }
    }

    private func symbol(for category: HymnCategory) -> String {
        let title = category.title.lowercased()

        if title.contains("praise") || title.contains("adoration") {
            return "hands.clap"
        } else if title.contains("worship") {
            return "sparkles"
        } else if title.contains("comfort") || title.contains("hope") {
            return "heart.text.square.fill"
        } else if title.contains("prayer") || title.contains("meditation") {
            return "hands.sparkles.fill"
        } else if title.contains("morning") {
            return "sunrise.fill"
        } else if title.contains("evening") {
            return "moon.stars.fill"
        } else if title.contains("sabbath") {
            return "sun.max.fill"
        } else if title.contains("advent") {
            return "sparkles"
        } else {
            return "book.pages"
        }
    }
}
