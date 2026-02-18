import SwiftUI

struct HomeView: View {
    let environment: AppEnvironment
    @StateObject private var viewModel: HomeViewModel
    @State private var path = NavigationPath()
    @ObservedObject private var favouritesService: FavouritesService

    @State private var isSearchPresented = false
    @State private var pendingHymnNavigation: Hymn?
    @State private var showQuickJump = false

    init(environment: AppEnvironment) {
        self.environment = environment
        self.favouritesService = environment.favouritesService
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(
                    hymnService: environment.hymnService,
                    recentlyViewedService: environment.recentlyViewedService
                )
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                content
            }
            .scrollIndicators(.hidden)

            // ✅ Hymn navigation (ONLY PLACE)
            .navigationDestination(for: Hymn.self) { hymn in
                HymnDetailView(
                    hymn: hymn,
                    environment: environment
                )
            }

            // ✅ Category navigation (ONLY PLACE)
            .navigationDestination(for: HymnCategory.self) { category in
                CategoryDetailView(
                    category: category,
                    hymns: environment.categoryViewModel.hymns(for: category),
                    environment: environment,
                    favouritesService: environment.favouritesService,
                    onSelectHymn: { hymn in
                        path.append(hymn)
                    }
                )
            }
            
//            .navigationDestination(for: String.self) { value in
//                if value == "categories" {
//                    CategoriesView(environment: environment)
//                }
//            }
        }
        // ✅ Search is isolated and safe
        .sheet(isPresented: $isSearchPresented, onDismiss: {
            if let hymn = pendingHymnNavigation {
                path.append(hymn)
                pendingHymnNavigation = nil
            }
        }) {
            NavigationStack {
                SearchResultsView(
                    environment: environment,
                    viewModel: environment.searchViewModel,
                    onSelectHymn: { hymn in
                        pendingHymnNavigation = hymn
                        isSearchPresented = false
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
                HymnOfTheDayHeader(
                    hymn: hymn,
                    onOpen: {
                        path.append(hymn)
                    }
                )
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
                                HymnCardView(
                                    hymn: hymn,
                                    isFavourite: favouritesService.isFavourite(hymn),
                                    onFavouriteToggle: {
                                        favouritesService.toggle(hymn)
                                    }
                                )
                                .frame(width: 180)
                                .onTapGesture {
                                    path.append(hymn)
                                }
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
//                onSeeAll: {
//                    path.append("categories")
//                },
                onSelect: { category in
                    print("Selected category: \(category)")
                    path.append(category)
                },
                environment: environment
            )
        }
        .padding()
    }
}
