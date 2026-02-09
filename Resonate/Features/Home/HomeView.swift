import SwiftUI

struct HomeView: View {
    let environment: AppEnvironment
    @StateObject private var viewModel: HomeViewModel
    @State private var path = NavigationPath()
    @ObservedObject private var favouritesService: FavouritesService
    
    init(environment: AppEnvironment) {
        self.environment = environment
        self.favouritesService = environment.favouritesService
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(hymnService: environment.hymnService)
        )
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                content
            }
            .scrollIndicators(.hidden)
            .navigationDestination(for: Hymn.self) { hymn in
                HymnDetailView(hymn: hymn, environment: environment)
            }
            .navigationDestination(for: HymnCategory.self) { category in
                CategoryDetailView(
                    category: category,
                    hymns: environment.categoryViewModel.hymns(for: category),
                    environment: environment
                )
            }
            .navigationDestination(for: String.self) { value in
                if value == "categories" {
                    CategoriesView(environment: environment)
                }
            }
        }
    }
    
    
    private var content: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            // Hymn of the Day
            if let hymn = viewModel.hymnOfTheDay {
                HymnOfTheDayHeader(
                    hymn: hymn,
                    onOpen: {
                        // push hymn reader
                        path.append(hymn)
                    }
                )
            }
            
            // Recently Viewed
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Recently Viewed")
                        .font(.headline)
                    Spacer()
                    Text("See all")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.recentlyViewed) { hymn in
                            NavigationLink(value: hymn) {
                                HymnCardView(
                                    hymn: hymn,
                                    isFavourite:environment.favouritesService.isFavourite(hymn),
                                    onFavouriteToggle: {
                                        favouritesService.toggle(hymn)
                                    }
                                ).frame(width: 180)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            // Classification (placeholder)
            HomeCategoriesSection(
                categories: environment.categoryViewModel.categories,
                counts: environment.categoryViewModel.hymnsByCategory
                    .mapValues { $0.count },
                onSeeAll: {
                    path.append("categories")
                },
                onSelect: { category in
                    path.append(category)
                }
            )
        }
        .padding()
    }
}


