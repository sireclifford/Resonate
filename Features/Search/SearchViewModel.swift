import Combine
import Foundation

final class SearchViewModel: ObservableObject {
    
    @Published var query: String = ""
    @Published var results: [SearchResult] = []
    
    private let hymnService: HymnService
    private var cancellables = Set<AnyCancellable>()
    
    private let analytics: AnalyticsService
    
    init(hymnService: HymnService,  analytics: AnalyticsService) {
        self.hymnService = hymnService
        self.analytics = analytics
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
        
        for index in hymnService.index {
            
            // 🔹 1️⃣ Exact hymn number match (priority)
            if let number = Int(trimmed), index.id == number {
                exactNumberMatch = SearchResult(
                    hymn: index,
                    matchedText: index.title,
                    verseIndex: nil,
                    lineIndex: nil
                )
            }
            
            // 🔹 2️⃣ Partial numeric match
            else if isNumeric, "\(index.id)".contains(trimmed) {
                matches.append(
                    SearchResult(
                        hymn: index,
                        matchedText: index.title,
                        verseIndex: nil,
                        lineIndex: nil
                    )
                )
            }
            
            // 🔹 3️⃣ Title match
            if index.title.lowercased().contains(lowercased) {
                matches.append(
                    SearchResult(
                        hymn: index,
                        matchedText: index.title,
                        verseIndex: nil,
                        lineIndex: nil
                    )
                )
            }
            
            // 🔹 4️⃣ Verses and 5️⃣ Chorus match with lazy detail fetch
            if let detail = hymnService.detail(for: index.id) {
                
                for (vIndex, verse) in detail.verses.enumerated() {
                    for (lIndex, line) in verse.enumerated() {
                        if line.lowercased().contains(lowercased) {
                            matches.append(
                                SearchResult(
                                    hymn: index,
                                    matchedText: line,
                                    verseIndex: vIndex,
                                    lineIndex: lIndex
                                )
                            )
                        }
                    }
                }
                
                if let chorus = detail.chorus {
                    for (lIndex, line) in chorus.enumerated() {
                        if line.lowercased().contains(lowercased) {
                            matches.append(
                                SearchResult(
                                    hymn: index,
                                    matchedText: line,
                                    verseIndex: nil,
                                    lineIndex: lIndex
                                )
                            )
                        }
                    }
                }
            }
        }
        
        // 🔹 Insert exact match at top if it exists
        if let exact = exactNumberMatch {
            matches.insert(exact, at: 0)
        }
        
        results = matches

        // Analytics
        if results.isEmpty {
            analytics.log(.searchEmptyResult)
        } else {
            analytics.log(
                .searchPerformed,
                parameters: [
                    .searchQuery: "performed",
                    .resultCount: results.count
                ]
            )
        }
    }
    
    func reset(){
        query = ""
        results = []
    }
}
