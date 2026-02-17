import Combine

final class AppEnvironment: ObservableObject {
    
    let hymnService: HymnService
    let persistenceService: PersistenceService
    let favouritesService: FavouritesService
    let tuneService: TuneService
    let audioPlaybackService: AudioPlaybackService
    let categoryViewModel: CategoryViewModel
    let searchViewModel: SearchViewModel
    let recentlyViewedService: RecentlyViewedService
    @Published var settingsService = AppSettingsService()
    
    init(
        hymnService: HymnService = HymnService(),
        persistenceService: PersistenceService = UserDefaultsStore()
    )
    {
        self.hymnService = HymnService()
        self.persistenceService = persistenceService
        self.favouritesService = FavouritesService(persistence: persistenceService)
        self.tuneService = TuneService()
        self.audioPlaybackService = AudioPlaybackService()
        self.categoryViewModel = CategoryViewModel(hymnService: hymnService)
        self.searchViewModel = SearchViewModel(
            hymnService: hymnService
        )
        self.recentlyViewedService = RecentlyViewedService()
    }
    
}
