import Combine
import YouVersionPlatform

final class AppEnvironment: ObservableObject {
    
    let hymnService: HymnService
    let persistenceService: PersistenceService
    let favouritesService: FavouritesService
    let tuneService: TuneService
    let sessionService: SessionService
    
    let categoryViewModel: CategoryViewModel
    let searchViewModel: SearchViewModel
    let recentlyViewedService: RecentlyViewedService
    let settingsService: AppSettingsService
    let hymnStoryService: HymnStoryService
    let analyticsService: AnalyticsService
    
    let notificationService: NotificationService
    let hymnOfTheDayEngagementService: HymnOfTheDayEngagementService
    let usageService: UsageService
    let recentSearchService: RecentSearchService
    
    @Published var notificationHymnID: Int?
    @Published var audioPlaybackService: AudioPlaybackService
    
    var pendingSessionSource: String? = nil
    
    init(
        hymnService: HymnService = HymnService(),
        persistenceService: PersistenceService = UserDefaultsStore()
    ) {
        self.analyticsService = AnalyticsService.shared
        self.settingsService = AppSettingsService(analytics: analyticsService)
        self.sessionService = SessionService(analytics: analyticsService,
                                             settingsService: settingsService)
        analyticsService.onMeaningfulInteraction = { [weak sessionService] in
            sessionService?.markInteraction()
        }
        
        self.hymnService = hymnService
        self.persistenceService = persistenceService
        self.usageService = UsageService()
        self.recentSearchService = RecentSearchService()
        
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
            self?.pendingSessionSource = "push_notification"
            self?.analyticsService.reminderNotificationTapped(hymnID: hymnID)
        }
    }
    
}
