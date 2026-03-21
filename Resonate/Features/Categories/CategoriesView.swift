import SwiftUI

enum BrowseSegment: String, CaseIterable, Identifiable {
    case themes = "Themes"
    case all = "All Hymns"
    var id: String { rawValue }
}

struct CategoriesView: View {
    let environment: AppEnvironment
    @StateObject private var viewModel: CategoryViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var segment: BrowseSegment = .themes
    @State private var isGrid = false
    @State private var searchText = ""
    @State private var selectedCategory: HymnCategory?
    @State private var lastSearchText = ""

    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = StateObject(
            wrappedValue: CategoryViewModel(
                hymnService: environment.hymnService
            )
        )
    }

    private var allHymns: [HymnIndex] {
        environment.hymnService.index
    }

    private var filteredHymns: [HymnIndex] {
        let base = selectedCategory != nil
            ? allHymns.filter { $0.category == selectedCategory }
            : allHymns

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return base }

        let queryLower = trimmed.lowercased()
        return base.filter { hymn in
            let textMatch = hymn.title.lowercased().contains(queryLower)
                || hymn.category.rawValue.lowercased().contains(queryLower)
            let numericMatch = String(hymn.id).contains(trimmed)
            return textMatch || numericMatch
        }
    }

    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 160), spacing: 16, alignment: .top)
    ]

    private var devotionalGroups: [DevotionalCategoryGroupSection] {
        let allGroups = DevotionalCategoryGroup.allCases.map { group in
            DevotionalCategoryGroupSection(
                group: group,
                categories: viewModel.categories.filter { group.categories.contains($0) }
            )
        }

        return allGroups.filter { !$0.categories.isEmpty }
    }

    private var featuredPaths: [HymnCategory] {
        [
            .meditation_and_prayer,
            .hope_and_comfort,
            .morning_worship,
            .sabbath
        ].filter { viewModel.categories.contains($0) }
    }

    var body: some View {
        ZStack {
            PremiumScreenBackground()

            VStack(spacing: 0) {
                Picker("", selection: $segment) {
                    ForEach(BrowseSegment.allCases) { seg in
                        Text(seg.rawValue).tag(seg)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 10)
                .background(PremiumTheme.panelFill(for: colorScheme).opacity(0.92))
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(PremiumTheme.border(for: colorScheme))
                        .frame(height: 1)
                }
                .onChange(of: segment) { _, newValue in
                    environment.analyticsService.log(
                        .tabSwitched,
                        parameters: [
                            .destination: newValue == .themes ? "browse_themes" : "browse_all",
                            .source: "categories"
                        ]
                    )
                }

                if segment == .themes {
                    themesBody
                } else {
                    allHymnsBody
                }
            }
        }
        .miniPlayerInset(using: environment)
    }

    private var themesBody: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                themesHero

                if !featuredPaths.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        sectionHeader(
                            title: "Begin With a Path",
                            subtitle: "Start from a devotional moment, not just a hymn taxonomy."
                        )

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(featuredPaths, id: \.self) { category in
                                    NavigationLink(value: category) {
                                        featuredPathCard(category)
                                    }
                                    .buttonStyle(.plain)
                                    .simultaneousGesture(
                                        TapGesture().onEnded {
                                            logCategoryOpen(category)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }

                ForEach(devotionalGroups) { section in
                    VStack(alignment: .leading, spacing: 14) {
                        sectionHeader(
                            title: section.group.title,
                            subtitle: section.group.subtitle
                        )

                        LazyVGrid(columns: adaptiveColumns, spacing: 16) {
                            ForEach(section.categories, id: \.self) { category in
                                NavigationLink(value: category) {
                                    devotionalCategoryCard(category)
                                }
                                .buttonStyle(.plain)
                                .simultaneousGesture(
                                    TapGesture().onEnded {
                                        logCategoryOpen(category)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var themesHero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Find a Path for This Moment")
                .font(PremiumTheme.titleFont(size: 31))
                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

            Text("Move through worship, comfort, prayer, hope, and sacred seasons with curated hymn pathways.")
                .font(PremiumTheme.bodyFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 28)
        .padding(.horizontal, 16)
    }

    private var allHymnsBody: some View {
        VStack(spacing: 12) {
            let trimmedPreviousQuery = lastSearchText.trimmingCharacters(in: .whitespacesAndNewlines)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                TextField(selectedCategory == nil ? "Search hymns" : "Search in \(selectedCategory!.title)", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .onChange(of: searchText) { oldValue, _ in
                        lastSearchText = oldValue
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        environment.analyticsService.log(
                            .searchCleared,
                            parameters: [
                                .previousQuery: trimmedPreviousQuery,
                                .source: "categories"
                            ]
                        )
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(PremiumTheme.searchFieldFill(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .onSubmit {
                environment.analyticsService.log(
                    .searchPerformed,
                    parameters: [
                        .resultCount: filteredHymns.count,
                        .searchQuery: searchText,
                        .source: "categories"
                    ]
                )
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ChipView(title: "All", selected: selectedCategory == nil) {
                        selectedCategory = nil
                        logCategoryOpen(nil)
                    }
                    ForEach(viewModel.categories) { category in
                        ChipView(title: category.title, selected: selectedCategory == category) {
                            selectedCategory = category
                            logCategoryOpen(category)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            HStack {
                Text("\(selectedCategory?.title ?? "All Hymns") (\(filteredHymns.count))")
                    .font(PremiumTheme.sectionTitleFont())
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isGrid.toggle()
                    }
                    environment.analyticsService.log(
                        .resultLayoutChanged,
                        parameters: [
                            .layout: isGrid ? "grid" : "list",
                            .source: "categories"
                        ]
                    )
                } label: {
                    Image(systemName: isGrid ? "list.bullet" : "square.grid.2x2")
                        .font(PremiumTheme.scaledSystem(size: 16, weight: .semibold))
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)

            Group {
                if isGrid {
                    ScrollView {
                        LazyVGrid(columns: adaptiveColumns, spacing: 14) {
                            ForEach(filteredHymns) { hymn in
                                NavigationLink(value: hymn) {
                                    HymnTileView(hymn: hymn)
                                }
                                .buttonStyle(.plain)
                                .simultaneousGesture(
                                    TapGesture().onEnded {
                                        logHymnOpen(hymn)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                    .scrollIndicators(.hidden)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(filteredHymns.enumerated()), id: \.element.id) { index, hymn in
                                NavigationLink {
                                    HymnDetailView(
                                        index: hymn,
                                        environment: environment,
                                        source: "categories"
                                    )
                                    .onAppear {
                                        logHymnOpen(hymn)
                                    }
                                } label: {
                                    HymnRowView(hymn: hymn)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                if index < filteredHymns.count - 1 {
                                    Divider()
                                        .overlay(PremiumTheme.border(for: colorScheme))
                                        .padding(.leading, 64)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationTitle("Browse")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(PremiumTheme.sectionTitleFont())
                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
            Text(subtitle)
                .font(PremiumTheme.bodyFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
        }
        .padding(.horizontal, 16)
    }

    private func devotionalCategoryCard(_ category: HymnCategory) -> some View {
        let descriptor = devotionalDescriptor(for: category)
        let symbol = symbol(for: category)

        return ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(PremiumTheme.panelFill(for: colorScheme))
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.0), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                )
                .shadow(color: PremiumTheme.shadow(for: colorScheme).opacity(0.36), radius: 12, y: 8)

            Image(systemName: symbol)
                .font(PremiumTheme.scaledSystem(size: 72, weight: .regular))
                .foregroundStyle(PremiumTheme.accent(for: colorScheme).opacity(colorScheme == .dark ? 0.12 : 0.16))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(14)

            VStack(alignment: .leading, spacing: 8) {
                Text(category.title)
                    .font(PremiumTheme.scaledSystem(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                    .lineLimit(2)

                Text(descriptor)
                    .font(PremiumTheme.bodyFont())
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    .lineLimit(2)

                Text("\(viewModel.hymns(for: category).count) hymns")
                    .font(PremiumTheme.captionFont())
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
            }
            .padding(18)
        }
        .frame(height: 182)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func featuredPathCard(_ category: HymnCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: symbol(for: category))
                    .font(PremiumTheme.scaledSystem(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }

            Text(category.title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)

            Text(devotionalDescriptor(for: category))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Text("\(viewModel.hymns(for: category).count) hymns")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(width: 220, alignment: .leading)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 24)
    }

    private func devotionalDescriptor(for category: HymnCategory) -> String {
        switch category {
        case .adoration_and_praise, .opening_of_worship, .glory_and_praise, .call_to_worship:
            return "For entering worship with reverence and praise."
        case .meditation_and_prayer:
            return "Hymns for stillness, confession, and listening before God."
        case .hope_and_comfort:
            return "For weary hearts seeking peace, courage, and assurance."
        case .morning_worship:
            return "A gentle place to begin the day with devotion."
        case .sda_hymnal_evening_worship:
            return "Quiet hymns for rest, gratitude, and evening reflection."
        case .sabbath:
            return "Songs shaped for Sabbath welcome, rest, and delight."
        case .second_advent:
            return "For longing, watchfulness, and the promise ahead."
        case .consecration, .repentance, .forgiveness:
            return "For surrender, renewal, and a softened heart."
        case .faith_and_trust, .guidance:
            return "For moments that call for trust and steady direction."
        default:
            return "A curated path for worship, reflection, and devotion."
        }
    }

    private func symbol(for category: HymnCategory) -> String {
        let title = category.title.lowercased()

        if title.contains("praise") || title.contains("adoration") {
            return "hands.clap"
        } else if title.contains("trinity") {
            return "bird.fill"
        } else if title.contains("worship") || title.contains("devotion") {
            return "sparkles"
        } else if title.contains("baptism") {
            return "drop.fill"
        } else if title.contains("birth") || title.contains("nativity") {
            return "star.fill"
        } else if title.contains("communion") {
            return "cup.and.saucer.fill"
        } else if title.contains("warfare") {
            return "shield.lefthalf.filled"
        } else if title.contains("dedication") || title.contains("consecration") {
            return "flame.fill"
        } else if title.contains("repentance") {
            return "drop.triangle.fill"
        } else if title.contains("comfort") || title.contains("hope") {
            return "heart.text.square.fill"
        } else if title.contains("forgiveness") || title.contains("mercy") || title.contains("grace") {
            return "hands.sparkles.fill"
        } else if title.contains("community") {
            return "person.2.fill"
        } else if title.contains("guidance") {
            return "lightbulb.fill"
        } else if title.contains("mission") {
            return "paperplane.fill"
        } else if title.contains("morning") {
            return "sunrise.fill"
        } else if title.contains("evening") {
            return "moon.stars.fill"
        } else if title.contains("faith") || title.contains("trust") {
            return "hands.and.sparkles.fill"
        } else if title.contains("joy") {
            return "face.smiling.fill"
        } else if title.contains("peace") || title.contains("rest") {
            return "dove.fill"
        } else if title.contains("cross") {
            return "cross.fill"
        } else {
            return "book.pages"
        }
    }

    private func logCategoryOpen(_ category: HymnCategory?) {
        environment.analyticsService.log(
            .categoryOpened,
            parameters: [
                .category: category?.title ?? "All",
                .source: "categories"
            ]
        )
    }

    private func logHymnOpen(_ hymn: HymnIndex) {
        environment.analyticsService.log(
            .hymnOpened,
            parameters: [
                .hymnID: String(hymn.id),
                .hymnTitle: hymn.title,
                .source: "categories"
            ]
        )
    }
}

private struct DevotionalCategoryGroupSection: Identifiable {
    let group: DevotionalCategoryGroup
    let categories: [HymnCategory]
    var id: String { group.rawValue }
}

private enum DevotionalCategoryGroup: String, CaseIterable {
    case worship
    case prayer
    case comfort
    case christianLife
    case sacredMoments

    var title: String {
        switch self {
        case .worship: return "Worship"
        case .prayer: return "Prayer & Reflection"
        case .comfort: return "Hope & Comfort"
        case .christianLife: return "Christian Life"
        case .sacredMoments: return "Seasonal & Sacred Moments"
        }
    }

    var subtitle: String {
        switch self {
        case .worship: return "Paths that gather the heart toward praise, awe, and reverence."
        case .prayer: return "Hymns for confession, stillness, surrender, and meditation."
        case .comfort: return "Collections for uncertainty, longing, peace, and promise."
        case .christianLife: return "Songs for discipleship, service, trust, and daily faithfulness."
        case .sacredMoments: return "Special moments in the worship calendar and life of the church."
        }
    }

    var categories: [HymnCategory] {
        switch self {
        case .worship:
            return [
                .adoration_and_praise, .opening_of_worship, .close_of_worship,
                .glory_and_praise, .call_to_worship, .love_of_god,
                .majesty_and_power_of_god, .faithfulness_of_god, .sda_hymnal_trinity
            ]
        case .prayer:
            return [
                .meditation_and_prayer, .repentance, .forgiveness,
                .consecration, .humility, .communion, .dedication
            ]
        case .comfort:
            return [
                .hope_and_comfort, .eternal_life, .joy_and_peace,
                .faith_and_trust, .guidance, .second_advent,
                .sda_hymnal_early_advent, .resurrection_of_the_saints
            ]
        case .christianLife:
            return [
                .community_in_christ, .mission_of_the_church, .loving_service,
                .obedience, .love_for_one_another, .watchfulness,
                .pilgrimage, .stewardship, .health_and_wholeness
            ]
        case .sacredMoments:
            return [
                .sabbath, .morning_worship, .sda_hymnal_evening_worship,
                .communion, .baptism, .ordination, .sda_hymnal_child_dedication,
                .birth, .first_advent, .resurrection_and_ascension
            ]
        }
    }
}

private struct ChipView: View {
    let title: String
    let selected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(PremiumTheme.scaledSystem(size: 14, weight: .semibold))
                .foregroundStyle(selected ? Color.white : PremiumTheme.primaryText(for: colorScheme))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Capsule()
                        .fill(selected ? PremiumTheme.accent(for: colorScheme) : PremiumTheme.subtleFill(for: colorScheme))
                )
                .overlay(
                    Capsule()
                        .stroke(selected ? .clear : PremiumTheme.border(for: colorScheme), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct HymnRowView: View {
    let hymn: HymnIndex
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(PremiumTheme.subtleFill(for: colorScheme))
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                Text("\(hymn.id)")
                    .font(PremiumTheme.scaledSystem(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                    .lineLimit(1)
                    .padding(.horizontal, 10)
            }
            .frame(minWidth: 44, minHeight: 44)
            .fixedSize(horizontal: true, vertical: false)

            VStack(alignment: .leading, spacing: 6) {
                Text(hymn.title)
                    .font(PremiumTheme.scaledSystem(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Image(systemName: "tag.fill")
                        .font(PremiumTheme.scaledSystem(size: 11, weight: .semibold))
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    Text(hymn.category.title)
                        .font(PremiumTheme.captionFont())
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                        .lineLimit(1)

                    Text("•")
                        .font(.caption)
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme).opacity(0.6))

                    Image(systemName: "text.justify.left")
                        .font(PremiumTheme.scaledSystem(size: 11, weight: .semibold))
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    Text("\(hymn.verseCount) verses")
                        .font(PremiumTheme.captionFont())
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(PremiumTheme.scaledSystem(size: 12, weight: .semibold))
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
        }
        .padding(.vertical, 12)
    }
}

private struct HymnTileView: View {
    let hymn: HymnIndex
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PremiumTheme.subtleFill(for: colorScheme))

            Image(systemName: "music.note.list")
                .font(PremiumTheme.scaledSystem(size: 42, weight: .semibold))
                .foregroundStyle(PremiumTheme.accent(for: colorScheme).opacity(colorScheme == .dark ? 0.16 : 0.13))
                .padding(.top, 18)
                .padding(.trailing, 16)

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    Text("\(hymn.id)")
                        .font(PremiumTheme.scaledSystem(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(PremiumTheme.searchFieldFill(for: colorScheme))
                        )
                        .overlay(
                            Capsule()
                                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                        )

                    Spacer(minLength: 8)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(hymn.title)
                        .font(PremiumTheme.scaledSystem(size: 18, weight: .semibold, design: .serif))
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        Text(hymn.category.title)
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                            .lineLimit(1)

                        Text("•")
                            .font(.caption)
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme).opacity(0.55))

                        Text("\(hymn.verseCount) verses")
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .frame(height: 182, alignment: .top)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
        )
    }
}
