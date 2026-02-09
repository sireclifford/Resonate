import Combine

final class AppEnvironment: ObservableObject {
    let hymnService: HymnService
    let persistenceService: PersistenceService
    let favouritesService: FavouritesService
    
    init(
        hymnService: HymnService = HymnService(),
        persistenceService: PersistenceService = UserDefaultsStore()
    )
    {
        self.hymnService = HymnService()
        self.persistenceService = persistenceService
        self.favouritesService = FavouritesService(persistence: persistenceService)
    }
    
}
