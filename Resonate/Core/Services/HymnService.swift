final class HymnService {
    private(set) var hymns: [Hymn] = []
    
    init(){
        loadHymns()
    }
    
    private func loadHymns(){
        do {
            hymns = try JSONLoader.load("hymns_en.json")
        } catch {
            assertionFailure("Failed to load hymns: \(error)")
        }
    }
    
    func hymn(by id: Int) -> Hymn? {
        hymns.first { $0.id == id}
    }
    
    func hymns(in category: HymnCategory) -> [Hymn] {
            hymns.filter { $0.category == category }
        }
}
