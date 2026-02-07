import Combine

final class AppEnvironment: ObservableObject {
    let hymnService: HymnService
    let persistenceService: PersistenceService
    
    init(
        hymnService: HymnService = HymnService(),
        persistenceService: PersistenceService = UserDefaultsStore()
    )
    {
        self.hymnService = HymnService()
        self.persistenceService = persistenceService
        
    }
    
}
