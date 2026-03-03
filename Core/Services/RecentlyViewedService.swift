import Foundation
import Combine

final class RecentlyViewedService: ObservableObject {

   
    private let defaults = UserDefaults.standard
    private let key = "recentlyViewed.hymnIDs"

    @Published private(set) var hymnIds: [Int] = []

    init() {
        hymnIds = defaults.array(forKey: key) as? [Int] ?? []
    }

    func record(id: Int) {
        var ids = hymnIds

        ids.removeAll { $0 == id }
        ids.insert(id, at: 0)

        hymnIds = ids
        defaults.set(ids, forKey: key)
    }

    func clear() {
        hymnIds = []
        defaults.removeObject(forKey: key)
    }
    
}
