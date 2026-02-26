import SwiftUI

struct HomeView: View {
    let environment: AppEnvironment
    let onSelectHymn: (HymnIndex) -> Void
    let onSeeAll: () -> Void
    
    @StateObject private var viewModel: HomeViewModel
    @ObservedObject private var favouritesService: FavouritesService
    @Environment(\.scenePhase) private var scenePhase
    @State private var midnightTimer: Timer?
    
    @State private var isSearchPresented = false
    
    init(environment: AppEnvironment, onSelectHymn: @escaping (HymnIndex) -> Void, onSeeAll: @escaping () -> Void) {
        
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
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                viewModel.refreshHymnOfTheDay()
            }
        }
        .onAppear {
            scheduleMidnightRefresh()
        }
        .onDisappear {
            midnightTimer?.invalidate()
        }
    }
    
    private var content: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            
            // Hymn of the Day
            if let hymn = viewModel.hymnOfTheDay {
                NavigationLink(value: hymn) {
                    HymnOfTheDayHeader(
                        index: hymn
                    )
                    .id(hymn.id)
                    .transition(.opacity)
//                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
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
                                        index: hymn,
                                        isFavourite: favouritesService.isFavourite(id: hymn.id),
                                        onFavouriteToggle: {
                                            favouritesService.toggle(id: hymn.id)
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
        //        .padding(.bottom, audioService.currentHymnID != nil ? 10 : 0)
    }
    
    private func scheduleMidnightRefresh() {
        midnightTimer?.invalidate()
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let nextMidnight = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) else { return }
        
        let interval = nextMidnight.timeIntervalSince(now)
        
        midnightTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.6)) {
                    viewModel.refreshHymnOfTheDay()
                }
                scheduleMidnightRefresh()
            }
        }
    }
}
