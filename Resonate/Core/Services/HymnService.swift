final class HymnService {
    
    private(set) var index: [HymnIndex] = []
    private var detailStorage: [Int: HymnDetail] = [:]
    
    init() {
        loadHymns()
    }
    
    private struct HymnDTO: Codable {
        let id: Int
        let title: String
        let verses: [[String]]
        let chorus: [String]?
        let category: HymnCategory
        let language: Language
    }
    
    private func loadHymns() {
        do {
            let fullHymns: [HymnDTO] = try JSONLoader.load("hymns_en.json")
            
            // Transform into index + detail storage
            for dto in fullHymns {
                
                let detail = HymnDetail(
                    id: dto.id,
                    verses: dto.verses,
                    chorus: dto.chorus
                )
                detailStorage[dto.id] = detail
                
                let item = HymnIndex(
                    id: dto.id,
                    title: dto.title,
                    category: dto.category,
                    language: dto.language,
                    verseCount: dto.verses.count
                )
                index.append(item)
            }
            
            // Keep sorted by id
            index.sort { $0.id < $1.id }
            
        } catch {
            assertionFailure("Failed to load hymns: \(error)")
        }
    }
    
    func hymnIndex(by id: Int) -> HymnIndex? {
        index.first { $0.id == id }
    }
    
    func detail(for id: Int) -> HymnDetail? {
        detailStorage[id]
    }
    
    func hymns(in category: HymnCategory) -> [HymnIndex] {
        index.filter { $0.category == category }
    }
    
    func hymn(after id: Int) -> HymnIndex? {
        guard let currentIndex = index.firstIndex(where: { $0.id == id }) else { return nil }
        let nextIndex = currentIndex + 1
        return index.indices.contains(nextIndex) ? index[nextIndex] : nil
    }
    
    func hymn(before id: Int) -> HymnIndex? {
        guard let currentIndex = index.firstIndex(where: { $0.id == id }) else { return nil }
        let previousIndex = currentIndex - 1
        return index.indices.contains(previousIndex) ? index[previousIndex] : nil
    }
}
