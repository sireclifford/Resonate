import Combine

final class FavouritesViewModel: ObservableObject {

    @Published var hymns: [HymnIndex] = []

    private let hymnService: HymnService
    private let favouritesService: FavouritesService

    init(hymnService: HymnService,
         favouritesService: FavouritesService) {
        self.hymnService = hymnService
        self.favouritesService = favouritesService
        load()
    }

    private func load() {
        let ids = favouritesService.favouriteIDs
        hymns = hymnService.index.filter { ids.contains($0.id) }
    }
}
