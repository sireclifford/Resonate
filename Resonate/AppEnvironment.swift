import Combine
import YouVersionPlatform

final class AppEnvironment: ObservableObject {
    
    let hymnService: HymnService
    let persistenceService: PersistenceService
    let favouritesService: FavouritesService
    let tuneService: TuneService
    @Published var audioPlaybackService: AudioPlaybackService
    let categoryViewModel: CategoryViewModel
    let searchViewModel: SearchViewModel
    let recentlyViewedService: RecentlyViewedService
    let settingsService: AppSettingsService
    let hymnStoryService: HymnStoryService
    
    init(
        hymnService: HymnService = HymnService(),
        persistenceService: PersistenceService = UserDefaultsStore()
    ) {
        
        self.hymnService = hymnService
        self.persistenceService = persistenceService
        
        // Settings first (because audio depends on it)
            self.settingsService = AppSettingsService()
        
        self.favouritesService = FavouritesService(persistence: persistenceService, settings: settingsService)
        self.tuneService = TuneService()
        self.recentlyViewedService = RecentlyViewedService()
        
        // Inject settings into audio service
            self.audioPlaybackService = AudioPlaybackService(
                settings: settingsService
            )
        self.categoryViewModel = CategoryViewModel(hymnService: hymnService)
        self.searchViewModel = SearchViewModel(
            hymnService: hymnService
        )
        self.hymnStoryService = HymnStoryService()
    }
    
}
