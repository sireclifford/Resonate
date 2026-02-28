import SwiftUI

struct HomeView: View {
    let environment: AppEnvironment
    let onSelectHymn: (HymnIndex) -> Void
    let onSeeAll: () -> Void
    
    @StateObject private var viewModel: HomeViewModel
    @ObservedObject private var favouritesService: FavouritesService
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
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
        VStack(alignment: .leading, spacing: 32) {
            
            // MARK: SEARCH
            GlobalSearchBar(
                viewModel: environment.searchViewModel,
                onActivate: {
                    isSearchPresented = true
                }
            )
            
            // MARK: DAILY HYMN (Hero)
            if let hymn = viewModel.hymnOfTheDay {
                VStack(alignment: .leading, spacing: 12) {
                    
                    NavigationLink(value: hymn) {
                        HymnOfTheDayHeader(index: hymn)
                            .id(hymn.id)
                            .padding(.vertical, 4)
                    }
                }
            }
            
            // MARK: CONTINUE
            VStack(alignment: .leading, spacing: 12) {
                
                Text("Continue")
                    .font(.title3.weight(.semibold))
                
                if viewModel.recentlyViewed.isEmpty {
                    
                    VStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 22))
                            .foregroundStyle(.secondary.opacity(0.5))
                        
                        Text("Your recent hymns will appear here.")
                            .font(.caption)
                            .foregroundStyle(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                } else {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(viewModel.recentlyViewed) { hymn in
                                NavigationLink(value: hymn) {
                                    HymnCardView(
                                        index: hymn,
                                        isFavourite: favouritesService.isFavourite(id: hymn.id),
                                        onFavouriteToggle: {
                                            favouritesService.toggle(id: hymn.id)
                                        }
                                    )
                                    .frame(width: 190)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            
            // MARK: THEMES (Curated + Horizontal)
            VStack(alignment: .leading, spacing: 16) {
                
                HStack {
                    Text("Themes")
                        .font(.title3.weight(.semibold))
                    
                    Spacer()
                    Button("See All") {
                        onSeeAll()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(environment.categoryViewModel.categories.prefix(6)) { category in
                            NavigationLink(value: category) {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text(category.title)
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(.white)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                        
                                        Spacer()
                                    }
                                }
                                .padding(24)
                                .frame(width: 190, height: 150, alignment: .topLeading)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(
                                            LinearGradient(
                                                colors: gradientColors(for: category),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    ZStack {
                                        Image(systemName: symbol(for: category))
                                            .font(.system(size: 90, weight: .regular))
                                            .foregroundStyle(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.12))
                                    }
                                )
                                .shadow(
                                    color: Color.black.opacity(0.12),
                                    radius: 14,
                                    y: 8
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.6), value: viewModel.hymnOfTheDay?.id)
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
    
    private func gradientColors(for category: HymnCategory) -> [Color] {
        let base = abs(category.id.hashValue)
        switch base % 4 {
        case 0:
            return [Color(red: 0.32, green: 0.36, blue: 0.62),
                    Color(red: 0.20, green: 0.24, blue: 0.45)]
        case 1:
            return [Color(red: 0.20, green: 0.48, blue: 0.35),
                    Color(red: 0.12, green: 0.32, blue: 0.24)]
        case 2:
            return [Color(red: 0.55, green: 0.42, blue: 0.22),
                    Color(red: 0.35, green: 0.26, blue: 0.12)]
        default:
            return [Color(red: 0.40, green: 0.30, blue: 0.50),
                    Color(red: 0.24, green: 0.18, blue: 0.32)]
        }
    }
    
    private func symbol(for category: HymnCategory) -> String {
        switch category.title.lowercased() {
        case let title where title.contains("praise"):
            return "hands.clap"
        case let title where title.contains("baptism"):
            return "drop.fill"
        case let title where title.contains("worship"):
            return "sparkles"
        case let title where title.contains("birth"):
            return "star.fill"
        default:
            return "book.closed"
        }
    }
}
