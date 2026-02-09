import SwiftUI

struct FavouritesView: View {

    let environment: AppEnvironment
    @StateObject private var viewModel: FavouritesViewModel
    @State private var path = NavigationPath()

    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = StateObject(
            wrappedValue: FavouritesViewModel(
                hymnService: environment.hymnService,
                favouritesService: environment.favouritesService
            )
        )
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if viewModel.hymns.isEmpty {
                    emptyState
                } else {
                    grid
                }
            }
            .navigationTitle("Favourite Hymns")
            .navigationDestination(for: Hymn.self) { hymn in
                HymnDetailView(
                    hymn: hymn,
                    environment: environment
                )
            }
        }
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.hymns) { hymn in
                    HymnCardView(
                        hymn: hymn,
                        isFavourite: true,
                        onFavouriteToggle: {
                            environment.favouritesService.toggle(hymn)
                        }
                    )
                    .onTapGesture {
                        path.append(hymn)
                    }
                }
            }
            .padding()
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
