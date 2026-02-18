import Combine

final class FavouritesService: ObservableObject {
    @Published private(set) var favouriteIDs: Set<Int> = []
    
    private let settings: AppSettingsService
    private let persistence: PersistenceService
    
    init(persistence: PersistenceService, settings: AppSettingsService){
        self.persistence = persistence
        self.settings = settings
        load()
    }
    
    func isFavourite(_ hymn: Hymn) -> Bool {
        favouriteIDs.contains(hymn.id)
    }
    
    func toggle(_ hymn: Hymn){
        if favouriteIDs.contains(hymn.id){
            favouriteIDs.remove(hymn.id)
        } else {
            favouriteIDs.insert(hymn.id)
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
