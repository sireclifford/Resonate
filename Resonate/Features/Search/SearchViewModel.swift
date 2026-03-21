import Combine
import Foundation

final class SearchViewModel: ObservableObject {
    
    @Published var query: String = ""
    @Published var results: [SearchResult] = []
    
    private let hymnService: HymnService
    private var cancellables = Set<AnyCancellable>()
    
    private let analytics: AnalyticsService
    private let searchQueue = DispatchQueue(label: "search.viewmodel.queue", qos: .userInitiated)
    private var searchDocuments: [SearchDocument] = []
    private var searchGeneration: UInt = 0
    private let maxResults = 40
    
    init(hymnService: HymnService,  analytics: AnalyticsService) {
        self.hymnService = hymnService
        self.analytics = analytics
        rebuildIndex()
        bind()
    }
    
    private func bind() {
        $query
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.search(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func rebuildIndex() {
        let hymnIndex = hymnService.index
        searchQueue.async { [weak self] in
            guard let self else { return }
            let documents = hymnIndex.map { index in
                SearchDocument(
                    hymn: index,
                    titleLowercased: index.title.lowercased(),
                    categoryLowercased: index.category.title.lowercased(),
                    lines: self.makeSearchLines(for: index.id)
                )
            }

            DispatchQueue.main.async {
                self.searchDocuments = documents
            }
        }
    }

    private func makeSearchLines(for hymnID: Int) -> [SearchLine] {
        guard let detail = hymnService.detail(for: hymnID) else { return [] }

        var lines: [SearchLine] = []

        for (verseIndex, verse) in detail.verses.enumerated() {
            for (lineIndex, line) in verse.enumerated() where !line.isEmpty {
                lines.append(
                    SearchLine(
                        text: line,
                        lowercased: line.lowercased(),
                        verseIndex: verseIndex,
                        lineIndex: lineIndex
                    )
                )
            }
        }

        if let chorus = detail.chorus {
            for (lineIndex, line) in chorus.enumerated() where !line.isEmpty {
                lines.append(
                    SearchLine(
                        text: line,
                        lowercased: line.lowercased(),
                        verseIndex: nil,
                        lineIndex: lineIndex
                    )
                )
            }
        }

        return lines
    }

    private func search(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            results = []
            return
        }

        let normalizedQuery = trimmed.lowercased()
        let exactNumber = Int(trimmed)
        let generation = searchGeneration &+ 1
        searchGeneration = generation
        let documents = searchDocuments

        searchQueue.async { [weak self] in
            guard let self else { return }

            let ranked = documents.compactMap { document in
                self.rank(document: document, query: trimmed, normalizedQuery: normalizedQuery, exactNumber: exactNumber)
            }
            .sorted {
                if $0.score == $1.score {
                    return $0.result.hymn.id < $1.result.hymn.id
                }
                return $0.score > $1.score
            }
            .prefix(self.maxResults)
            .map(\.result)

            DispatchQueue.main.async {
                guard self.searchGeneration == generation else { return }
                self.results = ranked

                if ranked.isEmpty {
                    self.analytics.log(.searchEmptyResult)
                } else {
                    self.analytics.log(
                        .searchPerformed,
                        parameters: [
                            .searchQuery: trimmed,
                            .resultCount: ranked.count
                        ]
                    )
                }
            }
        }
    }

    private func rank(
        document: SearchDocument,
        query: String,
        normalizedQuery: String,
        exactNumber: Int?
    ) -> RankedResult? {
        var bestScore = Int.min
        var bestText = document.hymn.title
        var bestVerseIndex: Int?
        var bestLineIndex: Int?

        if let exactNumber, document.hymn.id == exactNumber {
            bestScore = 1_000
        } else if Int(query) != nil, "\(document.hymn.id)".contains(query) {
            bestScore = 860
        }

        if document.titleLowercased == normalizedQuery {
            bestScore = max(bestScore, 950)
            bestText = document.hymn.title
        } else if document.titleLowercased.hasPrefix(normalizedQuery) {
            bestScore = max(bestScore, 900)
            bestText = document.hymn.title
        } else if document.titleLowercased.contains(normalizedQuery) {
            bestScore = max(bestScore, 820)
            bestText = document.hymn.title
        }

        if document.categoryLowercased.contains(normalizedQuery) {
            bestScore = max(bestScore, 540)
            bestText = document.hymn.category.title
            bestVerseIndex = nil
            bestLineIndex = nil
        }

        for line in document.lines {
            if line.lowercased == normalizedQuery {
                if 780 > bestScore {
                    bestScore = 780
                    bestText = line.text
                    bestVerseIndex = line.verseIndex
                    bestLineIndex = line.lineIndex
                }
            } else if line.lowercased.hasPrefix(normalizedQuery) {
                if 730 > bestScore {
                    bestScore = 730
                    bestText = line.text
                    bestVerseIndex = line.verseIndex
                    bestLineIndex = line.lineIndex
                }
            } else if line.lowercased.contains(normalizedQuery) {
                if 680 > bestScore {
                    bestScore = 680
                    bestText = line.text
                    bestVerseIndex = line.verseIndex
                    bestLineIndex = line.lineIndex
                }
            }
        }

        guard bestScore > Int.min else { return nil }

        return RankedResult(
            score: bestScore,
            result: SearchResult(
                hymn: document.hymn,
                matchedText: bestText,
                verseIndex: bestVerseIndex,
                lineIndex: bestLineIndex
            )
        )
    }
    
    func reset(){
        query = ""
        results = []
    }
}

private struct SearchDocument {
    let hymn: HymnIndex
    let titleLowercased: String
    let categoryLowercased: String
    let lines: [SearchLine]
}

private struct SearchLine {
    let text: String
    let lowercased: String
    let verseIndex: Int?
    let lineIndex: Int?
}

private struct RankedResult {
    let score: Int
    let result: SearchResult
}
