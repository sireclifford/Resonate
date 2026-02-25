import Combine

final class FavouritesService: ObservableObject {
    @Published private(set) var favouriteIDs: Set<Int> = []
    
    private let settings: AppSettingsService
    private let persistence: PersistenceService
    private let analyticsService: AnalyticsService
    
    init(persistence: PersistenceService, settings: AppSettingsService,analyticsService: AnalyticsService){
        self.persistence = persistence
        self.settings = settings
        self.analyticsService = analyticsService
        
        load()
    }
    
    func isFavourite(id: Int) -> Bool {
        favouriteIDs.contains(id)
    }
    
    func toggle(id: Int) {
        if favouriteIDs.contains(id) {
            favouriteIDs.remove(id)
            analyticsService.hymnUnfavourited(id: id)
        } else {
            favouriteIDs.insert(id)
            analyticsService.hymnFavourited(id: id)
        }
        
        save()
        if settings.enableHaptics {
            Haptics.light()
        }
    }
    
    private func load() {
        let ids: [Int] = persistence.load([Int].self, for: StorageKeys.favouriteHymnIDs) ?? []
        favouriteIDs = Set(ids)
    }
    
    private func save() {
        persistence.save(Array(favouriteIDs), for: StorageKeys.favouriteHymnIDs)
    }
    
}
