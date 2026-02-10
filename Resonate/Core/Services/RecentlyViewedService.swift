import Foundation
import Combine

final class RecentlyViewedService: ObservableObject {

    @Published private(set) var hymnIds: [Int] = []

    private let key = "recentlyViewedHymns"
    private let maxCount = 12

    init() {
        load()
    }

    func record(_ hymn: Hymn) {
        hymnIds.removeAll { $0 == hymn.id }
        hymnIds.insert(hymn.id, at: 0)

        if hymnIds.count > maxCount {
            hymnIds = Array(hymnIds.prefix(maxCount))
        }

        save()
    }

    private func save() {
        UserDefaults.standard.set(hymnIds, forKey: key)
    }

    private func load() {
        hymnIds = UserDefaults.standard.array(forKey: key) as? [Int] ?? []
    }
}
