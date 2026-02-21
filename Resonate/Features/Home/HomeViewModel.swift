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
        
        
        recentlyViewedService.$hymnIds
            .map { ids in
                ids.compactMap { id in
                    hymnService.hymnIndex(by: id)
                }
            }
            .assign(to: &$recentlyViewed)
        
        bindRecentlyViewed()
        computeHymnOfTheDay()
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
    
    private func computeHymnOfTheDay() {
        let hymns = hymnService.index
        guard !hymns.isEmpty else {
            hymnOfTheDay = nil
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let epoch = calendar.date(
            from: DateComponents(year: 2024, month: 1, day: 1)
        )!
        
        let days = calendar.dateComponents(
            [.day],
            from: epoch,
            to: today
        ).day ?? 0
        
        let index = days % hymns.count
        hymnOfTheDay = hymns[index]
    }
}
