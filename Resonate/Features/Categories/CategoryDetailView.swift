import SwiftUI

struct CategoryDetailView: View {

    let category: HymnCategory
    let hymns: [Hymn]
    let environment: AppEnvironment
    @ObservedObject var favouritesService: FavouritesService
    let onSelectHymn: (Hymn) -> Void

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
                    HymnCardView(
                        hymn: hymn,
                        isFavourite: favouritesService.isFavourite(hymn),
                        onFavouriteToggle: {
                            favouritesService.toggle(hymn)
                        }
                    )
                    .onTapGesture {
                        onSelectHymn(hymn)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Topics")
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}

