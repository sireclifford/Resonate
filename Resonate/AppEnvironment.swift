import Foundation
import Combine
import YouVersionPlatform

final class AppEnvironment: ObservableObject {
    
    let hymnService: HymnService
    let persistenceService: PersistenceService
    let favouritesService: FavouritesService
    let tuneService: TuneService
    let sessionService: SessionService
    let accompanimentStorageService: AccompanimentStorageService
    let accompanimentCacheService: AccompanimentCacheService
    let navigationService: NavigationService
    @Published var accompanimentPlaybackService: AccompanimentPlaybackService
    @Published var activeHymnDetailID: Int?
    
    let categoryViewModel: CategoryViewModel
    let searchViewModel: SearchViewModel
    let recentlyViewedService: RecentlyViewedService
    let settingsService: AppSettingsService
    let hymnStoryService: HymnStoryService
    let analyticsService: AnalyticsService

    // New notification architecture
    let dateProvider: DateProviding
    let authorizationManager: NotificationAuthorizationManaging
    let notificationClient: NotificationCenterClient
    let requestFactory: NotificationRequestFactory
    
    let reminderStateStore: ReminderStateStore
    let hotdContentBuilder: ReminderContentBuilding
    
    let hotdPolicy: ReminderPolicyEvaluating
    let reminderScheduler: ReminderScheduling
    let sabbathContentBuilder: ReminderContentBuilding
    let sabbathPolicy: ReminderPolicyEvaluating
    
    let reminderSettingsViewModel: ReminderSettingsViewModel
    
    let hymnOfTheDayEngagementService: HymnOfTheDayEngagementService
    let usageService: UsageService
    let recentSearchService: RecentSearchService
    
    let toastCenter: ToastCenter
    
    @Published var audioPlaybackService: AudioPlaybackService
    
    var pendingSessionSource: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
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
        self.accompanimentStorageService = AccompanimentStorageService()
        self.accompanimentCacheService = AccompanimentCacheService()
        self.navigationService = NavigationService()
        self.accompanimentPlaybackService = AccompanimentPlaybackService(
            storageService: accompanimentStorageService,
            cacheService: accompanimentCacheService,
            settings: settingsService,
            analyticsService: analyticsService,
            hymnTitleProvider: { id in
                hymnService.index.first(where: { $0.id == id })?.title ?? "Hymn \(id)"
            }
        )
        
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
        self.hymnOfTheDayEngagementService = HymnOfTheDayEngagementService(persistence: persistenceService)

        // New notification architecture
        self.dateProvider = SystemDateProvider()
        self.authorizationManager = NotificationAuthorizationManager()
        self.notificationClient = UserNotificationCenterClient()
        self.requestFactory = NotificationRequestFactory()
        self.reminderStateStore = UserDefaultsReminderStateStore()
        self.hotdContentBuilder = HOTDContentBuilder()
        self.hotdPolicy = HOTDReminderPolicy(
            dateProvider: dateProvider,
            contentBuilder: hotdContentBuilder
        )
        self.sabbathContentBuilder = SabbathContentBuilder()
        self.sabbathPolicy = SabbathReminderPolicy(
            dateProvider: dateProvider,
            contentBuilder: sabbathContentBuilder
        )
        self.reminderScheduler = ReminderScheduler(
            client: notificationClient,
            requestFactory: requestFactory,
            stateStore: reminderStateStore,
            hotdPolicy: hotdPolicy,
            sabbathPolicy: sabbathPolicy,
            dateProvider: dateProvider
        )
        self.reminderSettingsViewModel = ReminderSettingsViewModel(
            settings: settingsService,
            hymnService: hymnService,
            engagementService: hymnOfTheDayEngagementService,
            authorizationManager: authorizationManager,
            scheduler: reminderScheduler,
            dateProvider: dateProvider
        )
        self.toastCenter = ToastCenter()
    }
    
    @MainActor
    func onAppBecameActive() async {
        await reminderSettingsViewModel.onAppBecameActive()
    }
    
}
