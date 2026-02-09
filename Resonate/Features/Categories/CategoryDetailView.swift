import SwiftUI

struct CategoryDetailView: View {

    let category: HymnCategory
    let hymns: [Hymn]
    let environment: AppEnvironment

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
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
        .scrollIndicators(.hidden)
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
