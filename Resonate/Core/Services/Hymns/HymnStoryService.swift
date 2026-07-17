import Foundation

final class HymnStoryService {
    
    private(set) var storiesByID: [Int: HymnStory] = [:]
    
    init() {
        loadStories()
    }
    
    private func loadStories() {
        guard let url = Bundle.main.url(forResource: "hymns_merged", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([HymnStory].self, from: data)
        else {
            assertionFailure("Failed to load bundled hymn stories — check hymns_merged.json exists and is valid")
            return
        }
        
        storiesByID = Dictionary(uniqueKeysWithValues: decoded.map { ($0.hymnID, $0) })
    }
    
    func story(for id: Int) -> HymnStory? {
        storiesByID[id]
    }
}
