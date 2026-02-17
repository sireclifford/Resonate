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

        // Allow single-character searches; only guard against empty input
        guard !trimmed.isEmpty else {
            results = []
            return
        }

        let lowercased = trimmed.lowercased()
        var matches: [SearchResult] = []

        for hymn in hymnService.hymns {

            // 1. Number match
            if "\(hymn.id)".contains(lowercased) {
                matches.append(
                    SearchResult(
                        hymn: hymn,
                        matchedText: hymn.title,
                        verseIndex: nil,
                        lineIndex: nil
                    )
                )
            }

            // 2. Title match
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

            // 3. Verses
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

            // 4. Chorus (optional but recommended)
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

        results = matches
    }
    
    func reset(){
        query = ""
        results = []
    }
}

