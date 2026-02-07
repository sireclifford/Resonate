import Foundation

final class AppEnvironment: ObservableObject {
    let hymnService: HymnService
    let persistenceService: PersistenceService
    
    init(hymnService: HymnService = HymnService(),
         persistenceService: PersistenceService = PersistenceService())
    {
        self.hymnService = hymnService
        self.persistenceService = persistenceService
    }
}
