import Combine

final class FavouritesViewModel: ObservableObject {
    @Published var hymns: [Hymn] = []
    
    private let hymnService: HymnService
    private let favouriteService: FavouritesService
    private var cancellables = Set<AnyCancellable>()
    
    init(hymnService: HymnService, favouriteService: FavouritesService){
        self.hymnService = hymnService
        self.favouriteService = favouriteService
        
        favouriteService.$favouriteIDs.map { ids in
            hymnService.hymns.filter { ids.contains($0.id)
            }
        }
        .assign(to: &$hymns)
    }
}
