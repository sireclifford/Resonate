import Foundation
import Combine

final class FavouritesViewModel: ObservableObject {
    
    @Published var hymns: [HymnIndex] = []
    
    private let hymnService: HymnService
    private let favouritesService: FavouritesService
    private var cancellables = Set<AnyCancellable>()   // ← THIS LINE
    
    init(hymnService: HymnService,
         favouritesService: FavouritesService) {
        self.hymnService = hymnService
        self.favouritesService = favouritesService
        bind()
        load()
    }
    
    private func bind() {
        favouritesService.$favouriteIDs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.load()
            }
            .store(in: &cancellables)
    }
    
    
    private func load() {
        let ids = favouritesService.favouriteIDs
        hymns = hymnService.index.filter { ids.contains($0.id) }
    }
}
