import Combine

final class FavouritesViewModel: ObservableObject {
    @Published var hymns: [Hymn] = []
    
    private let hymnService: HymnService
    private let favouriteService: FavouritesService
    private var cancellables = Set<AnyCancellable>()
    
    init(hymnService: HymnService, favouritesService: FavouritesService){
        self.hymnService = hymnService
        self.favouriteService = favouritesService
        
        favouriteService.$favouriteIDs.map { ids in
            hymnService.hymns.filter { ids.contains($0.id)
            }
        }
        .assign(to: &$hymns)
    }
}
