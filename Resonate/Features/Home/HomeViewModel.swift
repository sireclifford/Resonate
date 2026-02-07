import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    let hymns: [Hymn]
    
    init(hymnService: HymnService) {
        self.hymns = hymnService.hymns
    }
}
