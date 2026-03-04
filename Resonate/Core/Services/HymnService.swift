import Foundation

final class HymnService {
    
    private struct WorshipMetadata {
        let scriptureRef: String
        let highlight: String
        let reflection: String
        let storyHint: String
    }

    private let worshipMetadata: [Int: WorshipMetadata] = [
        1: WorshipMetadata(
            scriptureRef: "Psalm 95:1",
            highlight: "O come, let us sing unto the Lord",
            reflection: "Worship begins when we turn our attention fully toward God. Let this hymn open your heart to praise.",
            storyHint: "This hymn has encouraged generations to begin worship with joy and reverence."
        ),
        2: WorshipMetadata(
            scriptureRef: "Proverbs 3:5–6",
            highlight: "Trust in the Lord with all thine heart",
            reflection: "Trust grows when we surrender control and lean on God's wisdom instead of our own.",
            storyHint: "The writer of this hymn learned deep trust through seasons of uncertainty."
        ),
        3: WorshipMetadata(
            scriptureRef: "Romans 15:13",
            highlight: "Joy and hope arise from faith",
            reflection: "Hope is not wishful thinking; it is confidence rooted in God's promises.",
            storyHint: "This hymn was written to remind believers that joy can coexist with hardship."
        )
    ]
    
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
                
                let meta = worshipMetadata[dto.id]
                
                let detail = HymnDetail(
                    id: dto.id,
                    verses: dto.verses,
                    chorus: dto.chorus,
                    scriptureRef: meta?.scriptureRef,
                    highlight: meta?.highlight,
                    storyHint: meta?.storyHint,
                    reflection: meta?.reflection
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
    
    func hymnOfTheDay(on date: Date = Date()) -> HymnIndex? {
        let hymns = index
        guard !hymns.isEmpty else { return nil }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)

        guard let epoch = calendar.date(
            from: DateComponents(year: 2024, month: 1, day: 1)
        ) else {
            return hymns.first
        }

        let days = calendar.dateComponents(
            [.day],
            from: epoch,
            to: today
        ).day ?? 0

        let safeIndex = abs(days) % hymns.count
        return hymns[safeIndex]
    }
}
