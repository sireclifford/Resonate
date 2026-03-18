import Combine

final class FavouritesService: ObservableObject {
    @Published private(set) var favouriteIDs: Set<Int> = []
    
    private let persistence: PersistenceService
    private let analyticsService: AnalyticsService
    private let settings: AppSettingsService
    private let toastCenter: ToastCenter
    private let hymnService: HymnService
    
    init(
        persistence: PersistenceService,
        settings: AppSettingsService,
        analyticsService: AnalyticsService,
        toastCenter: ToastCenter,
        hymnService: HymnService
    ) {
        self.persistence = persistence
        self.settings = settings
        self.analyticsService = analyticsService
        self.toastCenter = toastCenter
        self.hymnService = hymnService

        load()
    }
    
    func isFavourite(id: Int) -> Bool {
        favouriteIDs.contains(id)
    }
    
    func toggle(id: Int) {
        let hymnTitle = hymnService.hymnIndex(by: id)?.title ?? "Hymn"
        if favouriteIDs.contains(id) {
            favouriteIDs.remove(id)
            analyticsService.hymnUnfavourited(id: id)
            toastCenter.show(
                .success(
                    "\"\(hymnTitle)\" removed from favourites",
                ),
                position: .top
            )
        } else {
            favouriteIDs.insert(id)
            analyticsService.hymnFavourited(id: id)
            toastCenter.show(
                .success(
                    "\"\(hymnTitle)\" added to favourites",
                ),
                position: .top
            )
        }

        save()
        
            Haptics.light()
    }
    
    private func load() {
        let ids: [Int] = persistence.load([Int].self, for: StorageKeys.favouriteHymnIDs) ?? []
        favouriteIDs = Set(ids)
    }
    
    private func save() {
        persistence.save(Array(favouriteIDs), for: StorageKeys.favouriteHymnIDs)
    }
    
}
