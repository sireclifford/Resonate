import SwiftUI

struct CategoryDetailView: View {

    let category: HymnCategory
    let hymns: [Hymn]
    let environment: AppEnvironment
    @ObservedObject var favouritesService: FavouritesService

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hymns in \(category.title)")
                .font(.josefin(size: 18, weight: .semibold))
        }
        .padding(.horizontal)
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(hymns) { hymn in
                    NavigationLink(value: hymn) {
                        HymnCardView(
                            hymn: hymn,
                            isFavourite: favouritesService.isFavourite(hymn),
                            onFavouriteToggle: {
                                favouritesService.toggle(hymn)
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Hymn.self) { hymn in
            HymnDetailView(
                hymn: hymn,
                environment: environment
            )
        }
    }
}

