import Foundation
import Combine

final class HomeViewModel: ObservableObject {

    let hymns: [Hymn]

    init(hymnService: HymnService) {
        self.hymns = hymnService.hymns
    }

    var recentlyViewed: [Hymn] {
        Array(hymns.prefix(5))
    }

    var hymnOfTheDay: Hymn? {
        hymns.first
    }
}
