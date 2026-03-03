import SwiftUI

struct HomeView: View {
    let environment: AppEnvironment
    let onSelectHymn: (HymnIndex) -> Void
    let onSeeAll: () -> Void

    @StateObject private var viewModel: HomeViewModel
    @ObservedObject private var favouritesService: FavouritesService
    @ObservedObject private var settingsService: AppSettingsService
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @State private var midnightTimer: Timer?

    @State private var isSearchPresented = false
    @State private var pendingAutoOpenHymnOfDay = false

    init(environment: AppEnvironment, onSelectHymn: @escaping (HymnIndex) -> Void, onSeeAll: @escaping () -> Void) {

        self.environment = environment
        self.onSelectHymn = onSelectHymn
        self.onSeeAll = onSeeAll
        self.favouritesService = environment.favouritesService
        self.settingsService = environment.settingsService
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(
                hymnService: environment.hymnService,
                recentlyViewedService: environment.recentlyViewedService
            )
        )
    }
    
    
    private var isEarlyUser: Bool {
        environment.settingsService.meaningfulSessionCount < 3
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.refreshHymnOfTheDay()
            }
        }
        .onChange(of: settingsService.shouldAutoOpenHymnOfDay) { _, newValue in
            if newValue {
                attemptAutoOpenHymnOfTheDayIfNeeded()
            }
        }
        .onChange(of: viewModel.hymnOfTheDay?.id) { _, _ in
            attemptAutoOpenHymnOfTheDayIfNeeded()
        }
        .onAppear {
            scheduleMidnightRefresh()
            viewModel.refreshHymnOfTheDay()
            attemptAutoOpenHymnOfTheDayIfNeeded()
        }
        .onDisappear {
            midnightTimer?.invalidate()
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 32) {

            // SEARCH
            GlobalSearchBar(
                viewModel: environment.searchViewModel,
                onActivate: {
                    isSearchPresented = true
                }
            )

            // DAILY HYMN (Hero)
            if let hymn = viewModel.hymnOfTheDay {
                VStack(alignment: .leading, spacing: 12) {

                    NavigationLink(value: hymn) {
                        HymnOfTheDayHeader(index: hymn)
                            .id(hymn.id)
                            .padding(.vertical, 4)
                    }
                }
            }

            // CONTINUE + START HERE
            VStack(alignment: .leading, spacing: 18) {

                // Continue (only when we have recently viewed hymns)
                if !viewModel.recentlyViewed.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Continue")
                            .font(.title3.weight(.semibold))

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
                // Start Here (always available)
                VStack(alignment: .leading, spacing: 12) {
                    if isEarlyUser {
                        Text("New Here?")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    Text("Start Here")
                        .font(.title3.weight(.semibold))
                    VStack(spacing: 12) {

                        Button {
                            // TODO: Replace with a curated “Most Loved” list.
                            onSeeAll()
                        } label: {
                            startHereCard(
                                title: "Most Loved Hymns",
                                subtitle: "Beloved by the community",
                                systemImage: "heart.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            // TODO: Replace with an Editor’s Picks curated list.
                            onSeeAll()
                        } label: {
                            startHereCard(
                                title: "Editor’s Picks",
                                subtitle: "A gentle place to begin",
                                systemImage: "star.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        if let hymn = viewModel.hymnOfTheDay {
                            Button {
                                DispatchQueue.main.async {
                                    onSelectHymn(hymn)
                                }
                            } label: {
                                startHereCard(
                                    title: "Featured Reflection Hymn",
                                    subtitle: "Today’s hymn for quiet worship",
                                    systemImage: "sparkles"
                                )
                            }
                            .buttonStyle(.plain)
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

    // Light Mode: premium solid card. Dark Mode: glass card.
    private func startHereCard(title: String, subtitle: String, systemImage: String) -> some View {
        Group {
            if colorScheme == .dark {
                // Glass card style (dark mode)
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(.thinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.55),
                                                Color.white.opacity(0.08)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )

                        Image(systemName: systemImage)
                            .font(.system(size: 17, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.accentColor)
                    }
                    .frame(width: 42, height: 42)
                    .shadow(color: Color.black.opacity(0.10), radius: 10, y: 6)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(subtitle)
                            .font(.subheadline)
                            .opacity(0.75)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(.thinMaterial)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.45),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 14, y: 8)
                .overlay(
                    // subtle top highlight
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                        .mask(
                            LinearGradient(
                                colors: [Color.white, Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                )
            } else {
                // Premium solid card style (light mode)
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.accentColor.opacity(0.95),
                                        Color.accentColor.opacity(0.55)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Image(systemName: systemImage)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 42, height: 42)
                    .shadow(color: Color.black.opacity(0.10), radius: 6, y: 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(subtitle)
                            .font(.subheadline)
                            .opacity(0.75)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.primary.opacity(0.05))
                        )
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary.opacity(0.08))
                )
                .shadow(color: Color.black.opacity(0.06), radius: 10, y: 6)
            }
        }
    }

    private func attemptAutoOpenHymnOfTheDayIfNeeded() {
        // If the trigger flipped, consume it immediately and mark pending
        if settingsService.shouldAutoOpenHymnOfDay {
            settingsService.shouldAutoOpenHymnOfDay = false
            pendingAutoOpenHymnOfDay = true
            viewModel.refreshHymnOfTheDay()
        }

        guard pendingAutoOpenHymnOfDay else { return }
        guard let hymn = viewModel.hymnOfTheDay else { return }

        pendingAutoOpenHymnOfDay = false

        environment.analyticsService.reminderHymnOpened(hymnID: hymn.id)

        DispatchQueue.main.async {
            onSelectHymn(hymn)
        }
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

