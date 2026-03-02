import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    
    @Published private(set) var recentlyViewed: [HymnIndex] = []
    @Published private(set) var hymnOfTheDay: HymnIndex?
    
    private let hymnService: HymnService
    private let recentlyViewedService: RecentlyViewedService
    private var cancellables = Set<AnyCancellable>()
    
    init(
        hymnService: HymnService,
        recentlyViewedService: RecentlyViewedService
    ) {
        self.hymnService = hymnService
        self.recentlyViewedService = recentlyViewedService
        
        refreshHymnOfTheDay()
        bindRecentlyViewed()
    }
    
    private func bindRecentlyViewed() {
        recentlyViewedService.$hymnIds
            .map { [weak self] ids in
                guard let self else { return [] }
                return ids.compactMap { id in
                    self.hymnService.hymnIndex(by: id)
                }
            }
            .receive(on: RunLoop.main)
            .assign(to: &$recentlyViewed)
    }
    
    func refreshHymnOfTheDay() {
        hymnOfTheDay = hymnService.hymnOfTheDay()
    }
    
}
