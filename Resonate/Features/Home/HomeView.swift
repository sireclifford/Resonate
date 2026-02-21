import SwiftUI

struct HomeView: View {
    let environment: AppEnvironment
    let onSelectHymn: (Hymn) -> Void
    let onSeeAll: () -> Void
    @StateObject private var viewModel: HomeViewModel
    @ObservedObject private var favouritesService: FavouritesService
    
    @State private var isSearchPresented = false
    
    init(environment: AppEnvironment, onSelectHymn: @escaping (Hymn) -> Void, onSeeAll: @escaping () -> Void) {
        self.environment = environment
        self.onSelectHymn = onSelectHymn
        self.onSeeAll = onSeeAll
        self.favouritesService = environment.favouritesService
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(
                hymnService: environment.hymnService,
                recentlyViewedService: environment.recentlyViewedService
            )
        )
    }
    
    var body: some View {
        ScrollView {
            content
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $isSearchPresented) {
            NavigationStack {
                SearchResultsView(
                    environment: environment,
                    viewModel: environment.searchViewModel,
                    onSelectHymn: { hymn in
                        isSearchPresented = false
                        DispatchQueue.main.async {
                            onSelectHymn(hymn)
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Content
    
    private var content: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            
            // Hymn of the Day
            if let hymn = viewModel.hymnOfTheDay {
                NavigationLink(value: hymn) {
                    HymnOfTheDayHeader(
                        hymn: hymn
                    )
                }
            }
            
            // Global Search
            GlobalSearchBar(
                viewModel: environment.searchViewModel,
                onActivate: {
                    isSearchPresented = true
                }
            )
            
            // Recently Viewed (FIXED)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Recently Viewed")
                        .font(.headline)
                    Spacer()
                }
                if viewModel.recentlyViewed.isEmpty {
                    RecentlyViewedPlaceholder()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.recentlyViewed) { hymn in
                                NavigationLink(value: hymn) {
                                    HymnCardView(
                                        hymn: hymn,
                                        isFavourite: favouritesService.isFavourite(hymn),
                                        onFavouriteToggle: {
                                            favouritesService.toggle(hymn)
                                        }
                                    )
                                    .frame(width: 180)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            
            // Categories (TYPE-SAFE ONLY)
            HomeCategoriesSection(
                categories: environment.categoryViewModel.categories,
                counts: environment.categoryViewModel.hymnsByCategory
                    .mapValues { $0.count },
                onSeeAll: onSeeAll,
                environment: environment
            )
        }
        .padding()
    }
}
