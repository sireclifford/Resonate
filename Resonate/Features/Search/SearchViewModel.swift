import Combine
import Foundation

final class SearchViewModel: ObservableObject {

    @Published var query: String = ""
    @Published var results: [SearchResult] = []

    private let hymnService: HymnService
    private var cancellables = Set<AnyCancellable>()

    init(hymnService: HymnService) {
        self.hymnService = hymnService
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

    private func search(query: String) {

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Only guard against empty input
        guard !trimmed.isEmpty else {
            results = []
            return
        }

        let lowercased = trimmed.lowercased()
        let isNumeric = Int(trimmed) != nil

        var matches: [SearchResult] = []
        var exactNumberMatch: SearchResult?

        for hymn in hymnService.hymns {

            // 🔹 1️⃣ Exact hymn number match (priority)
            if let number = Int(trimmed), hymn.id == number {
                exactNumberMatch = SearchResult(
                    hymn: hymn,
                    matchedText: hymn.title,
                    verseIndex: nil,
                    lineIndex: nil
                )
            }

            // 🔹 2️⃣ Partial numeric match
            else if isNumeric, "\(hymn.id)".contains(trimmed) {
                matches.append(
                    SearchResult(
                        hymn: hymn,
                        matchedText: hymn.title,
                        verseIndex: nil,
                        lineIndex: nil
                    )
                )
            }

            // 🔹 3️⃣ Title match
            if hymn.title.lowercased().contains(lowercased) {
                matches.append(
                    SearchResult(
                        hymn: hymn,
                        matchedText: hymn.title,
                        verseIndex: nil,
                        lineIndex: nil
                    )
                )
            }

            // 🔹 4️⃣ Verses match
            for (vIndex, verse) in hymn.verses.enumerated() {
                for (lIndex, line) in verse.enumerated() {
                    if line.lowercased().contains(lowercased) {
                        matches.append(
                            SearchResult(
                                hymn: hymn,
                                matchedText: line,
                                verseIndex: vIndex,
                                lineIndex: lIndex
                            )
                        )
                    }
                }
            }

            // 🔹 5️⃣ Chorus match
            if let chorus = hymn.chorus {
                for (lIndex, line) in chorus.enumerated() {
                    if line.lowercased().contains(lowercased) {
                        matches.append(
                            SearchResult(
                                hymn: hymn,
                                matchedText: line,
                                verseIndex: nil,
                                lineIndex: lIndex
                            )
                        )
                    }
                }
            }
        }

        // 🔹 Insert exact match at top if it exists
        if let exact = exactNumberMatch {
            matches.insert(exact, at: 0)
        }

        results = matches
    }
    
    func reset(){
        query = ""
        results = []
    }
}

