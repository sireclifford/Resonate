import SwiftUI

struct SearchResultsView: View {

    let environment: AppEnvironment
    @ObservedObject var viewModel: SearchViewModel
    let onSelectHymn: (HymnIndex) -> Void

    @FocusState private var isSearchFocused: Bool
    
    @ObservedObject private var usageService: UsageService
    @ObservedObject private var recentSearchService: RecentSearchService
    
    init(environment: AppEnvironment, viewModel: SearchViewModel, onSelectHymn: @escaping (HymnIndex) -> Void) {
        self.environment = environment
        self.viewModel = viewModel
        self.onSelectHymn = onSelectHymn
        _usageService = ObservedObject(wrappedValue: environment.usageService)
        _recentSearchService = ObservedObject(wrappedValue: environment.recentSearchService)
    }

    private var isNumericQuery: Bool {
        Int(viewModel.query) != nil
    }

    private var exactMatch: HymnIndex? {
        guard let number = Int(viewModel.query) else { return nil }
        return environment.hymnService.index.first { $0.id == number }
    }

    private var frequentHymns: [HymnIndex] {
        let ids = environment.usageService
            .topHymns(limit: 3)
            .filter { !environment.recentSearchService.recent.contains($0) }

        return ids.compactMap { id in
            environment.hymnService.index.first { $0.id == id }
        }
    }

    private var recentHymns: [HymnIndex] {
        environment.recentSearchService.recent.prefix(3).compactMap { id in
            environment.hymnService.index.first { $0.id == id }
        }
    }

    var body: some View {
        VStack {
            searchField

            if viewModel.query.isEmpty {
                suggestionsView
            } else {
                resultsView
            }
        }
        .navigationTitle("Search")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFocused = true
            }
        }
        .onSubmit {
            if let hymn = exactMatch {
                open(hymn)
            }
        }
    }

    private var searchField: some View {
        TextField("Search hymns, numbers, lyrics…", text: $viewModel.query)
            .keyboardType(.numbersAndPunctuation)
            .submitLabel(.search)
            .focused($isSearchFocused)
            .textFieldStyle(.roundedBorder)
            .padding()
    }

    private var suggestionsView: some View {
        List {
            if !recentHymns.isEmpty {
                Section {
                    ForEach(recentHymns) { hymn in
                        Button {
                            open(hymn)
                        } label: {
                            Text("Hymn \(hymn.id) – \(hymn.title)")
                        }
                    }
                } header: {
                    HStack {
                        Text("Recently Opened")
                        Spacer()
                        Button("Clear") {
                            environment.recentSearchService.clear()
                        }
                        .font(.caption)
                    }
                }
            }

            if !frequentHymns.isEmpty {
                Section("Frequently Opened") {
                    ForEach(frequentHymns) { hymn in
                        Button {
                            open(hymn)
                        } label: {
                            Text("Hymn \(hymn.id) – \(hymn.title)")
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private var resultsView: some View {
        List {
            if let hymn = exactMatch {
                Section("Exact Match") {
                    Button {
                        open(hymn)
                    } label: {
                        Text("Hymn \(hymn.id) – \(hymn.title)")
                            .fontWeight(.semibold)
                    }
                }
            }

            Section("Results") {
                ForEach(viewModel.results) { result in
                    Button {
                        open(result.hymn)
                    } label: {
                        SearchResultRow(
                            result: result,
                            highlightedSnippet: highlightedText(result.matchedText, query: viewModel.query)
                        )
                    }
                }
            }
        }
        .listStyle(.plain)
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
                attributed[attributedRange].foregroundColor = .accentColor
                attributed[attributedRange].backgroundColor = .accentColor.opacity(0.15)
            }

            searchRange = range.upperBound..<lowercasedText.endIndex
        }

        return attributed
    }
}
