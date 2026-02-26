import Combine
import YouVersionPlatform

final class AppEnvironment: ObservableObject {
    
    let hymnService: HymnService
    let persistenceService: PersistenceService
    let favouritesService: FavouritesService
    let tuneService: TuneService
    
    let categoryViewModel: CategoryViewModel
    let searchViewModel: SearchViewModel
    let recentlyViewedService: RecentlyViewedService
    let settingsService: AppSettingsService
    let hymnStoryService: HymnStoryService
    let analyticsService: AnalyticsService
    
    let notificationService: NotificationService
    let hymnOfTheDayEngagementService: HymnOfTheDayEngagementService

    @Published var notificationHymnID: Int?
    @Published var audioPlaybackService: AudioPlaybackService
    
    init(
        hymnService: HymnService = HymnService(),
        persistenceService: PersistenceService = UserDefaultsStore()
    ) {
        self.analyticsService = AnalyticsService.shared
        self.hymnService = hymnService
        self.persistenceService = persistenceService
        
        // Settings first (because audio depends on it)
        self.settingsService = AppSettingsService(analytics: analyticsService)
        
        self.favouritesService = FavouritesService(persistence: persistenceService, settings: settingsService,
                                                   analyticsService: analyticsService
        )
        self.tuneService = TuneService()
        self.recentlyViewedService = RecentlyViewedService()
        
        // Inject settings into audio service
        self.audioPlaybackService = AudioPlaybackService(
            settings: settingsService,
            analyticsService: analyticsService
        )
        self.categoryViewModel = CategoryViewModel(hymnService: hymnService)
        self.searchViewModel = SearchViewModel(
            hymnService: hymnService,
            analytics: analyticsService
        )
        self.hymnStoryService = HymnStoryService()
        
        self.notificationService = NotificationService()
        self.hymnOfTheDayEngagementService = HymnOfTheDayEngagementService(persistence: persistenceService)

        self.notificationService.onNotificationTapped = { [weak self] hymnID in
            self?.notificationHymnID = hymnID
        }
    }
    
}
