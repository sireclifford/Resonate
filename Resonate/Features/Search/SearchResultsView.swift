import SwiftUI

struct SearchResultsView: View {
    let environment: AppEnvironment
    @ObservedObject var viewModel: SearchViewModel
    let onSelectHymn: (HymnIndex) -> Void

    @FocusState private var isSearchFocused: Bool
    @ObservedObject private var usageService: UsageService
    @ObservedObject private var recentSearchService: RecentSearchService
    @Environment(\.colorScheme) private var colorScheme

    init(environment: AppEnvironment, viewModel: SearchViewModel, onSelectHymn: @escaping (HymnIndex) -> Void) {
        self.environment = environment
        self.viewModel = viewModel
        self.onSelectHymn = onSelectHymn
        _usageService = ObservedObject(wrappedValue: environment.usageService)
        _recentSearchService = ObservedObject(wrappedValue: environment.recentSearchService)
    }

    private var exactMatch: HymnIndex? {
        guard let number = Int(viewModel.query) else { return nil }
        return environment.hymnService.index.first { $0.id == number }
    }

    private var frequentHymns: [HymnIndex] {
        let ids = usageService
            .topHymns(limit: 4)
            .filter { !recentSearchService.recent.contains($0) }

        return ids.compactMap { id in
            environment.hymnService.index.first { $0.id == id }
        }
    }

    private var recentHymns: [HymnIndex] {
        recentSearchService.recent.prefix(4).compactMap { id in
            environment.hymnService.index.first { $0.id == id }
        }
    }

    var body: some View {
        ZStack {
            PremiumScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    searchField

                    if viewModel.query.isEmpty {
                        suggestionsView
                    } else {
                        resultsView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .miniPlayerInset(using: environment)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isSearchFocused = true
            }
        }
        .onSubmit {
            if let hymn = exactMatch {
                open(hymn)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Search")
                .font(PremiumTheme.titleFont(size: 34))
                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

            Text("Find a hymn by title, number, or a remembered line, then return to it quickly.")
                .font(PremiumTheme.bodyFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                .lineSpacing(3)
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(PremiumTheme.scaledSystem(size: 15, weight: .semibold))
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))

            TextField("Search hymns, numbers, lyrics…", text: $viewModel.query)
                .keyboardType(.numbersAndPunctuation)
                .submitLabel(.search)
                .focused($isSearchFocused)
                .font(PremiumTheme.scaledSystem(size: 16, weight: .medium))
                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                .tint(PremiumTheme.accent(for: colorScheme))

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.reset()
                } label: {
                    Image(systemName: "xmark")
                        .font(PremiumTheme.scaledSystem(size: 11, weight: .bold))
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(PremiumTheme.subtleFill(for: colorScheme))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(PremiumTheme.searchFieldFill(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: PremiumTheme.shadow(for: colorScheme).opacity(0.32), radius: 9, y: 4)
    }

    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            introPanel

            if !recentHymns.isEmpty {
                suggestionSection(
                    title: "Recently Opened",
                    actionTitle: "Clear",
                    action: { recentSearchService.clear() },
                    hymns: recentHymns
                )
            }

            if !frequentHymns.isEmpty {
                suggestionSection(
                    title: "Frequently Opened",
                    actionTitle: nil,
                    action: nil,
                    hymns: frequentHymns
                )
            }
        }
    }

    private var introPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Begin with what you remember.")
                .font(PremiumTheme.titleFont(size: 28))
                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

            Text("Use a hymn number, a title, or a line that stayed with you. Recent and frequent hymns are kept close so returning feels effortless.")
                .font(PremiumTheme.bodyFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                .lineSpacing(3)
        }
        .padding(20)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 28)
    }

    private func suggestionSection(
        title: String,
        actionTitle: String?,
        action: (() -> Void)?,
        hymns: [HymnIndex]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title.uppercased())
                        .font(PremiumTheme.eyebrowFont())
                        .tracking(1.2)
                        .foregroundStyle(PremiumTheme.accent(for: colorScheme))

                    Text(title)
                        .font(PremiumTheme.scaledSystem(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                }

                Spacer()

                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .font(PremiumTheme.captionFont())
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                }
            }

            VStack(spacing: 12) {
                ForEach(hymns) { hymn in
                    Button {
                        open(hymn)
                    } label: {
                        searchSuggestionCard(for: hymn)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func searchSuggestionCard(for hymn: HymnIndex) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                PremiumTheme.accent(for: colorScheme).opacity(0.95),
                                PremiumTheme.accent(for: colorScheme).opacity(0.60)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("\(hymn.id)")
                    .font(PremiumTheme.scaledSystem(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(hymn.title)
                    .font(PremiumTheme.scaledSystem(size: 19, weight: .semibold, design: .serif))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                    .lineLimit(1)

                Text("Hymn \(hymn.id)")
                    .font(PremiumTheme.scaledSystem(size: 14, weight: .medium))
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(PremiumTheme.scaledSystem(size: 13, weight: .semibold))
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                .padding(10)
                .background(
                    Circle()
                        .fill(PremiumTheme.subtleFill(for: colorScheme))
                )
                .overlay(
                    Circle()
                        .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(PremiumTheme.panelFill(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: PremiumTheme.shadow(for: colorScheme).opacity(0.45), radius: 10, y: 5)
    }

    private var resultsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let hymn = exactMatch {
                resultSection(
                    eyebrow: "EXACT MATCH",
                    title: "Hymn \(hymn.id)",
                    subtitle: "Open the hymn directly",
                    content: {
                        Button {
                            open(hymn)
                        } label: {
                            searchSuggestionCard(for: hymn)
                        }
                        .buttonStyle(.plain)
                    }
                )
            }

            resultSection(
                eyebrow: viewModel.results.isEmpty ? "NO RESULTS" : "RESULTS",
                title: viewModel.results.isEmpty ? "Nothing matched yet" : "\(viewModel.results.count) matching hymns",
                subtitle: viewModel.results.isEmpty
                    ? "Try a hymn number, another lyric phrase, or a shorter title."
                    : "Search results are ordered by the strongest match to what you typed.",
                content: {
                    if viewModel.results.isEmpty {
                        emptyResultsCard
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.results) { result in
                                Button {
                                    open(result.hymn)
                                } label: {
                                    SearchResultRow(
                                        result: result,
                                        highlightedSnippet: highlightedText(result.matchedText, query: viewModel.query)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            )
        }
    }

    private func resultSection<Content: View>(
        eyebrow: String,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(eyebrow)
                    .font(PremiumTheme.eyebrowFont())
                    .tracking(1.2)
                    .foregroundStyle(PremiumTheme.accent(for: colorScheme))

                Text(title)
                    .font(PremiumTheme.scaledSystem(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

                Text(subtitle)
                    .font(PremiumTheme.bodyFont())
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    .lineSpacing(3)
            }

            content()
        }
    }

    private var emptyResultsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Search by hymn number, title, or a lyric phrase.")
                .font(PremiumTheme.scaledSystem(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

            Text("Examples: “523”, “How Great Thou Art”, or a memorable line from the verse or chorus.")
                .font(PremiumTheme.bodyFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                .lineSpacing(3)
        }
        .padding(18)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 24)
    }

    private func open(_ hymn: HymnIndex) {
        isSearchFocused = false
        onSelectHymn(hymn)
        environment.analyticsService.searchResultTapped(id: hymn.id)
        viewModel.reset()
    }

    func highlightedText(_ text: String, query: String) -> AttributedString {
        var attributed = AttributedString(text)

        guard !query.isEmpty else { return attributed }

        let lowercasedText = text.lowercased()
        let lowercasedQuery = query.lowercased()
        var searchRange = lowercasedText.startIndex..<lowercasedText.endIndex

        while let range = lowercasedText.range(of: lowercasedQuery, options: [], range: searchRange) {
            if let attributedRange = Range(range, in: attributed) {
                attributed[attributedRange].foregroundColor = UIColor(PremiumTheme.accent(for: colorScheme))
                attributed[attributedRange].backgroundColor = UIColor(PremiumTheme.accent(for: colorScheme).opacity(0.18))
            }

            searchRange = range.upperBound..<lowercasedText.endIndex
        }

        return attributed
    }
}
