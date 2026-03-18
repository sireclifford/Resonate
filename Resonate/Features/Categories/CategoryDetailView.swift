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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                hero

                VStack(alignment: .leading, spacing: 10) {
                    Text("Hymns in This Path")
                        .font(.title3.weight(.semibold))

                    Text("\(hymns.count) hymns gathered for \(category.title.lowercased()).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground),
                    Color(.secondarySystemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle(category.title)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: symbol(for: category))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(hymns.count) hymns")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.5))
                    )
                    .clipShape(Capsule())
            }

            Text(category.title)
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(.primary)

            Text(devotionalDescriptor(for: category))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark
                            ? [
                                Color(red: 0.19, green: 0.18, blue: 0.20),
                                Color(red: 0.12, green: 0.12, blue: 0.14)
                            ]
                            : [
                                Color(red: 0.95, green: 0.93, blue: 0.87),
                                Color(red: 0.90, green: 0.87, blue: 0.80)
                            ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.24 : 0.06), radius: 18, y: 10)
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
