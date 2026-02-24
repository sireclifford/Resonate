import SwiftUI

struct FavouritesView: View {

    let environment: AppEnvironment
    @StateObject private var viewModel: FavouritesViewModel
    @ObservedObject private var audioService: AudioPlaybackService

    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = StateObject(
            wrappedValue: FavouritesViewModel(
                hymnService: environment.hymnService,
                favouritesService: environment.favouritesService
            )
        )
        
        _audioService = ObservedObject(
               wrappedValue: environment.audioPlaybackService
           )
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Group {
            if viewModel.hymns.isEmpty {
                emptyState
            } else {
                grid
            }
        }
        .navigationTitle("Favourite Hymns")
    }

    private var grid: some View {
        ZStack(alignment: .bottom) {

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.hymns) { index in
                        NavigationLink(value: index) {
                            HymnCardView(
                                index: index,
                                isFavourite: true,
                                onFavouriteToggle: {
                                    environment.favouritesService.toggle(id: index.id)
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
//                .padding(.bottom, audioService.currentHymnID != nil ? 100 : 0)
            }

//            if audioService.currentHymnID != nil {
//                MiniPlayerView(environment: environment)
//                    .environmentObject(environment)
//                    .padding(.horizontal)
//                    .padding(.bottom, 8)
//            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No favourites yet")
                .font(.headline)

            Text("Tap the heart icon on a hymn to save it here.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
