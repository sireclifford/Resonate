import SwiftUI

struct CategoryDetailView: View {

    let category: HymnCategory
    let hymns: [Hymn]
    let environment: AppEnvironment

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(hymns) { hymn in
                    NavigationLink(value: hymn) {
                        HymnCardView(
                            hymn: hymn,
                            isFavourite: environment.favouritesService.isFavourite(hymn),
                            onFavouriteToggle: {
                                environment.favouritesService.toggle(hymn)
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Hymn.self) { hymn in
            HymnDetailView(
                hymn: hymn,
                environment: environment
            )
        }
    }
}
