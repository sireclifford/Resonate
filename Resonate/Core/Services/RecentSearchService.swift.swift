import Foundation
import Combine

final class RecentSearchService: ObservableObject {
    
    @Published private(set) var recent: [Int] = []
    
    private let storageKey = "recent_searches"
    private let maxItems = 10
    
    init() {
        load()
    }
    
    func add(_ hymnID: Int) {
        recent.removeAll { $0 == hymnID }
        recent.insert(hymnID, at: 0)
        
        if recent.count > maxItems {
            recent.removeLast()
        }
        
        save()
    }
    
    func clear() {
        recent.removeAll()
        save()
    }
    
    private func save() {
        UserDefaults.standard.set(recent, forKey: storageKey)
    }
    
    private func load() {
        recent = UserDefaults.standard.array(forKey: storageKey) as? [Int] ?? []
    }
}
