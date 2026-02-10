import Foundation
import Combine

final class HomeViewModel: ObservableObject {

    // MARK: - Published UI State

    @Published private(set) var recentlyViewed: [Hymn] = []
    @Published private(set) var hymnOfTheDay: Hymn?

    // MARK: - Dependencies

    private let hymnService: HymnService
    private let recentlyViewedService: RecentlyViewedService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        hymnService: HymnService,
        recentlyViewedService: RecentlyViewedService
    ) {
        self.hymnService = hymnService
        self.recentlyViewedService = recentlyViewedService

        bindRecentlyViewed()
        computeHymnOfTheDay()
    }

    // MARK: - Recently Viewed Binding

    private func bindRecentlyViewed() {
        recentlyViewedService.$hymnIds
            .map { [weak self] ids in
                guard let self else { return [] }
                return ids.compactMap { self.hymnService.hymn(by: $0) }
            }
            .receive(on: RunLoop.main)
            .assign(to: &$recentlyViewed)
    }

    // MARK: - Hymn of the Day

    private func computeHymnOfTheDay() {
        let hymns = hymnService.hymns
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
