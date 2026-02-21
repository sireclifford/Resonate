import Foundation
import Combine

final class RecentlyViewedService: ObservableObject {

   
    private let defaults = UserDefaults.standard
    private let key = "recentlyViewed.hymnIDs"

    @Published private(set) var hymnIds: [Int] = []

    init() {
        hymnIds = defaults.array(forKey: key) as? [Int] ?? []
    }

    func record(_ hymn: Hymn) {
        var ids = hymnIds

        ids.removeAll { $0 == hymn.id }
        ids.insert(hymn.id, at: 0)

        hymnIds = ids
        defaults.set(ids, forKey: key)
    }

    func clear() {
        hymnIds = []
        defaults.removeObject(forKey: key)
    }
    
}
