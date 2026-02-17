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
    
    func hymn(after hymn: Hymn) -> Hymn? {
        guard let index = hymns.firstIndex(where: { $0.id == hymn.id }) else { return nil }
        let nextIndex = index + 1
        return hymns.indices.contains(nextIndex) ? hymns[nextIndex] : nil
    }
    
    func hymn(before hymn: Hymn) -> Hymn? {
        guard let index = hymns.firstIndex(where: { $0.id == hymn.id }) else { return nil }
        let previousIndex = index - 1
        return hymns.indices.contains(previousIndex) ? hymns[previousIndex] : nil
    }
}
