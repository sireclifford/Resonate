import Combine

final class DevotionViewModel: ObservableObject {
    @Published var index: HymnIndex?
    @Published var detail: HymnDetail?
    
    private let hymnService: HymnService
    let hymnID: Int
    
    init(hymnID: Int, hymnService: HymnService) {
        self.hymnID = hymnID
        self.hymnService = hymnService
        
        self.index = hymnService.hymnIndex(by: hymnID)
        self.detail = hymnService.detail(for: hymnID)
    }
    
    var title: String {
        index?.title ?? "Hymn \(hymnID)"
    }
    
    var verseCount: Int {
        detail?.verses.count ?? 0
    }
    
    func lines(for verseIndex: Int) -> [String] {
        guard let d = detail, d.verses.indices.contains(verseIndex) else { return [] }
        return d.verses[verseIndex]
    }
    
    // TODO: Add support for audio availability
    // TODO: Add reflection text sourced from scripture
}
