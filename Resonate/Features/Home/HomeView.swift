import SwiftUI

struct HomeView: View {
    let environment: AppEnvironment
    let onSelectHymn: (HymnIndex) -> Void
    let onSeeAll: () -> Void
    let onRoute: (HomeRoute) -> Void

    @StateObject private var viewModel: HomeViewModel
    @ObservedObject private var favouritesService: FavouritesService
    @ObservedObject private var settingsService: AppSettingsService
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @State private var midnightTimer: Timer?
    @State private var greetingTimer: Timer?
    @State private var greetingTick = false

    @State private var isSearchPresented = false
    @State private var pendingAutoOpenHymnOfTheDay = false

    init(
        environment: AppEnvironment,
        onSelectHymn: @escaping (HymnIndex) -> Void,
        onSeeAll: @escaping () -> Void,
        onRoute: @escaping (HomeRoute) -> Void
    ) {

        self.environment = environment
        self.onSelectHymn = onSelectHymn
        self.onSeeAll = onSeeAll
        self.onRoute = onRoute
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
    
    @State private var showWorshipFlow = false
    @State private var worshipStart: Date?
    @State private var worshipCounted = false
    
    private var greeting: String {
        // Boundaries: Night 21:00–6:00, Morning 6:00–12:00, Afternoon 12:00–18:00, Evening 18:00–21:00
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "Good Morning"
        case 12..<18:
            return "Good Afternoon"
        case 18..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    private var isHymnOfDayNotificationsOn: Bool {
        settingsService.dailyReminderEnabled
    }

    private var greetingIconName: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "sunrise.fill"     // Morning
        case 12..<18:
            return "sun.max.fill"     // Afternoon
        case 18..<21:
            return "sunset.fill"      // Evening
        default:
            return "moon.stars.fill"  // Night
        }
    }

    private var greetingGradient: LinearGradient {
        if colorScheme == .dark {
            switch greetingIconName {
            case "sunrise.fill":
                return LinearGradient(colors: [Color.orange, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
            case "sun.max.fill":
                return LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            case "sunset.fill":
                return LinearGradient(colors: [Color.pink, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            default:
                return LinearGradient(colors: [Color.indigo, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        } else {
            switch greetingIconName {
            case "sunrise.fill":
                return LinearGradient(colors: [Color.orange.opacity(0.9), Color.pink.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
            case "sun.max.fill":
                return LinearGradient(colors: [Color.yellow.opacity(0.9), Color.orange.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
            case "sunset.fill":
                return LinearGradient(colors: [Color.pink.opacity(0.9), Color.purple.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
            default:
                return LinearGradient(colors: [Color.indigo.opacity(0.9), Color.blue.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }

    @State private var greetingIconScale: CGFloat = 1.0

    @ViewBuilder
    private func GreetingIcon() -> some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.primary.opacity(0.06))
                .frame(width: 36, height: 36)
                .overlay(
                    Circle().stroke(
                        colorScheme == .dark ? Color.white.opacity(0.18) : Color.primary.opacity(0.08),
                        lineWidth: 1
                    )
                )
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.10), radius: 6, y: 3)

            Image(systemName: greetingIconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(greetingGradient)
                .symbolRenderingMode(.palette)
                .scaleEffect(greetingIconScale)
        }
        .onAppear {
            // Force an obvious breathing amplitude and speed
            greetingIconScale = 1.0
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    greetingIconScale = 1.30
                }
            }
        }
        .onChange(of: greetingTick) { _, _ in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                greetingIconScale = 1.45
            }
            // Light haptic to reinforce boundary change
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
            #endif
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    greetingIconScale = 1.30
                }
            }
        }
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
            prefetchHomeAudioAvailability()
        }
        .onChange(of: viewModel.recentlyViewed.map(\.id)) { _, _ in
            prefetchHomeAudioAvailability()
        }
        .onAppear {
            scheduleMidnightRefresh()
            scheduleGreetingRefresh()
            viewModel.refreshHymnOfTheDay()
            attemptAutoOpenHymnOfTheDayIfNeeded()
            prefetchHomeAudioAvailability()
        }
        .onDisappear {
            midnightTimer?.invalidate()
            greetingTimer?.invalidate()
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 32) {
            GreetingRow
            SearchSection
            DailyHymnHero
            ContinueAndStartHereSection
            ThemesSection
        }
        .padding()
        .animation(.easeInOut(duration: 0.6), value: viewModel.hymnOfTheDay?.id)
    }

    private var GreetingRow: some View {
        HStack(spacing: 10) {
            GreetingIcon()

            Text(greeting + ",")
                .id(greetingTick)
                .font(.title2.weight(.bold))
            Text("Friend")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "bell.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.primary.opacity(0.78))
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(colorScheme == .dark ? Color.white.opacity(0.10) : Color.primary.opacity(0.05))
                )
                .overlay(
                    Circle().stroke(
                        colorScheme == .dark ? Color.white.opacity(0.20) : Color.primary.opacity(0.08),
                        lineWidth: 1
                    )
                )
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.22 : 0.08), radius: 8, y: 4)
                .accessibilityLabel(isHymnOfDayNotificationsOn ? "Notifications On" : "Notifications Off")
        }
    }

    private var SearchSection: some View {
        GlobalSearchBar(
            viewModel: environment.searchViewModel,
            onActivate: {
                environment.analyticsService.log(
                    .searchPerformed,
                    parameters: [
                        .source: "home",
                        .searchQuery: "activated"
                    ]
                )
                isSearchPresented = true
            }
        )
    }

    private var DailyHymnHero: some View {
        Group {
            if let hymn = viewModel.hymnOfTheDay {
                VStack(alignment: .leading, spacing: 12) {
                    ZStack(alignment: .bottomLeading) {
                        let cardShape = RoundedRectangle(cornerRadius: 26, style: .continuous)
                        let palette = hotdGradientColors(for: hymn.id)

                        DailyHymnCardBackground(cardShape: cardShape, palette: palette, colorScheme: colorScheme)

                        VStack {}
                            .frame(maxWidth: .infinity)
                            .frame(height: 118)
                            .background(
                                LinearGradient(
                                    colors: colorScheme == .dark
                                        ? [Color.black.opacity(0.62), Color.black.opacity(0.08)]
                                        : [Color.white.opacity(0.52), Color.white.opacity(0.06)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .clipShape(cardShape)
                            .allowsHitTesting(false)

                        HStack(alignment: .center, spacing: 12) {
                            // Left label: Hymn of the Day
                            Text("Hymn of the Day")
                                .font(.footnote.weight(.semibold))
                                .textCase(.uppercase)
                                .tracking(0.8)
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.82) : .secondary)

                            Spacer()

                            // Right pill: Today
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Today")
                                    .font(.caption.weight(.semibold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(.thinMaterial)
                            .overlay(
                                Capsule().stroke(
                                    colorScheme == .dark ? Color.white.opacity(0.16) : Color.black.opacity(0.08),
                                    lineWidth: 1
                                )
                            )
                            .clipShape(Capsule())
                            .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.92) : .primary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .allowsHitTesting(false)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("#\(hymn.id) • \(hymn.title)")
                                .font(.headline.weight(.semibold))
                                .lineSpacing(1)
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.95) : .primary)
                                .lineLimit(2)

                            Text("A moment of quiet worship")
                                .font(.system(size: 17, weight: .semibold, design: .serif))
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.90) : .primary.opacity(0.90))
                                .lineSpacing(2)
                                .lineLimit(2)
                                .padding(.top, 1)

                            Group {
                                if !isHymnOfDayNotificationsOn {
                                    Button {
                                        Task {
                                            await environment.reminderSettingsViewModel.requestPermissionAndEnableHOTD()

                                            let formatter = DateFormatter()
                                            formatter.timeStyle = .short
                                            formatter.dateStyle = .none
                                            let timeString = formatter.string(from: environment.reminderSettingsViewModel.hotdTime)

                                            if environment.reminderSettingsViewModel.hotdEnabled {
                                                environment.analyticsService.notificationPromptAccepted()
                                                environment.analyticsService.reminderScheduled(timeBucket: timeString)
                                                environment.toastCenter.show(
                                                    .success(
                                                        "Daily reminder enabled",
                                                        subtitle: "You’ll be reminded at \(timeString)"
                                                    ),
                                                    position: .top
                                                )
                                            } else {
                                                environment.analyticsService.notificationPromptDeclined()
                                                environment.toastCenter.show(
                                                    .error(
                                                        "Notifications not enabled",
                                                        subtitle: "Please allow notifications in your app settings to receive daily reminders."
                                                    ),
                                                    position: .bottom
                                                )
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "paperplane.fill")
                                                .font(.system(size: 14, weight: .semibold))
                                            Text("Send Me This Daily")
                                                .font(.subheadline.weight(.semibold))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(.thinMaterial)
                                        .overlay(
                                            Capsule().stroke(
                                                colorScheme == .dark ? Color.white.opacity(0.18) : Color.primary.opacity(0.10),
                                                lineWidth: 1
                                            )
                                        )
                                        .clipShape(Capsule())
                                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.primary)
                                        .shadow(color: Color.black.opacity(0.18), radius: 10, y: 6)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    HStack(spacing: 8) {
                                        Image(systemName: "bell.badge.waveform")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Daily reminder is on")
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(.thinMaterial)
                                    .overlay(
                                        Capsule().stroke(
                                            colorScheme == .dark ? Color.white.opacity(0.16) : Color.primary.opacity(0.10),
                                            lineWidth: 1
                                        )
                                    )
                                    .clipShape(Capsule())
                                    .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.92) : Color.primary)
                                    .shadow(color: Color.black.opacity(0.10), radius: 8, y: 5)
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel("Daily hymn reminder is enabled")
                                }
                            }
                            .padding(.top, 14)
                        }
                        .frame(maxWidth: 315, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)
                        .padding(.bottom, 14)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    }
                    .frame(maxWidth: .infinity, minHeight: 208)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        environment.analyticsService.log(
                            .tabSwitched,
                            parameters: [
                                .source: "home",
                                .destination: "worship_flow_from_hotd_card"
                            ]
                        )
                        showWorshipFlow = true
                    }
                }
                .fullScreenCover(isPresented: $showWorshipFlow) {
                    if let hymn = viewModel.hymnOfTheDay {
                        WorshipFlowContainer(
                            hymnID: hymn.id,
                            environment: environment
                        )
                        .onAppear {
                            worshipStart = Date()
                            worshipCounted = false
                        }
                        .onDisappear {
                            if let start = worshipStart {
                                let dwell = Date().timeIntervalSince(start)
                                if dwell >= 10, !worshipCounted {
                                    environment.hymnOfTheDayEngagementService.markOpened(hymnID: hymn.id)
                                    worshipCounted = true
                                }
                            }
                            worshipStart = nil
                        }
                    } else {
                        Text("Preparing worship…")
                            .font(.headline)
                            .padding()
                    }
                }
            }
        }
    }

    private struct DailyHymnCardBackground: View {
        let cardShape: RoundedRectangle
        let palette: (Color, Color)
        let colorScheme: ColorScheme

        private var baseFillGradient: some ShapeStyle {
            LinearGradient(
                colors: [
                    palette.0.opacity(colorScheme == .dark ? 0.90 : 0.55),
                    palette.1.opacity(colorScheme == .dark ? 0.75 : 0.35)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        private var topHighlightFill: some ShapeStyle {
            RadialGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.10 : 0.16),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 10,
                endRadius: 220
            )
        }

        private var bottomVignetteFill: some ShapeStyle {
            RadialGradient(
                colors: [
                    Color.black.opacity(colorScheme == .dark ? 0.55 : 0.20),
                    Color.clear
                ],
                center: .bottom,
                startRadius: 40,
                endRadius: 320
            )
        }

        private var strokeGradient: LinearGradient {
            LinearGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.22 : 0.18),
                    Color.white.opacity(0.00)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        var body: some View {
            // Build base with shadows in a simple step
            let base = cardShape
                .fill(baseFillGradient)
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.10),
                    radius: 18,
                    y: 10
                )
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.22 : 0.06),
                    radius: 6,
                    y: 3
                )

            // Precompose each overlay to simplify type-checking
            let topHighlight = cardShape
                .fill(topHighlightFill)
                .blendMode(.overlay)
                .allowsHitTesting(false)

            let bottomVignette = cardShape
                .fill(bottomVignetteFill)
                .blendMode(.multiply)
                .allowsHitTesting(false)

            let darkGlass: AnyView = {
                if colorScheme == .dark {
                    return AnyView(
                        cardShape
                            .fill(.ultraThinMaterial)
                            .opacity(0.35)
                            .allowsHitTesting(false)
                    )
                } else {
                    return AnyView(EmptyView())
                }
            }()

            let primaryStroke = cardShape
                .stroke(strokeGradient, lineWidth: 1)
                .allowsHitTesting(false)

            let secondaryStroke = cardShape
                .stroke(
                    colorScheme == .dark
                    ? Color.white.opacity(0.10)
                    : Color.black.opacity(0.06),
                    lineWidth: 1
                )
                .allowsHitTesting(false)

            let watermark = Image(systemName: "music.note")
                .resizable()
                .scaledToFit()
                .frame(width: 90)
                .foregroundStyle(
                    colorScheme == .dark
                    ? Color.white.opacity(0.07)
                    : Color.black.opacity(0.06)
                )
                .offset(x: 48, y: -10)

            return base
                .overlay(topHighlight)
                .overlay(bottomVignette)
                .overlay(darkGlass)
                .overlay(primaryStroke)
                .overlay(secondaryStroke)
                .overlay(watermark, alignment: .topTrailing)
        }
    }

    private var ContinueAndStartHereSection: some View {
        VStack(alignment: .leading, spacing: 18) {
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
                        environment.analyticsService.log(
                            .tabSwitched,
                            parameters: [
                                .source: "home",
                                .destination: "browse_most_loved"
                            ]
                        )
                        onRoute(.mostLoved)
                    } label: {
                        startHereCard(
                            title: "Most Loved Hymns",
                            subtitle: "Beloved by the community",
                            systemImage: "heart.fill"
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        environment.analyticsService.log(
                            .tabSwitched,
                            parameters: [
                                .source: "home",
                                .destination: "browse_editors_picks"
                            ]
                        )
                        onRoute(.editorsPicks)
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
                                environment.analyticsService.log(
                                    .categoryOpened,
                                    parameters: [
                                        .category: "featured_reflection_home",
                                        .hymnID: hymn.id
                                    ]
                                )
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
    }

    private var ThemesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Themes")
                    .font(.title3.weight(.semibold))

                Spacer()
                Button("See All") {
                    environment.analyticsService.log(
                        .tabSwitched,
                        parameters: [
                            .source: "home",
                            .destination: "browse_themes"
                        ]
                    )
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
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                environment.analyticsService.log(
                                    .categoryOpened,
                                    parameters: [
                                        .category: category.title,
                                        .source: "home"
                                    ]
                                )
                            }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
            .scrollContentBackground(.hidden)
        }
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

    private func prefetchHomeAudioAvailability() {
        var hymnIDs = Set<Int>()

        if let hotdID = viewModel.hymnOfTheDay?.id {
            hymnIDs.insert(hotdID)
        }

        for hymn in viewModel.recentlyViewed {
            hymnIDs.insert(hymn.id)
        }

        guard !hymnIDs.isEmpty else { return }

        Task {
            await environment.accompanimentStorageService.prefetchAvailability(for: Array(hymnIDs))
        }
    }

    private func attemptAutoOpenHymnOfTheDayIfNeeded() {
        // If the trigger flipped, consume it immediately and mark pending
        if settingsService.shouldAutoOpenHymnOfDay {
            settingsService.shouldAutoOpenHymnOfDay = false
            pendingAutoOpenHymnOfTheDay = true
            viewModel.refreshHymnOfTheDay()
        }

        guard pendingAutoOpenHymnOfTheDay else { return }
        guard let hymn = viewModel.hymnOfTheDay else { return }

        pendingAutoOpenHymnOfTheDay = false

        environment.analyticsService.reminderHymnOpened(hymnID: hymn.id)

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
//        let timeString = formatter.string(from: environment.reminderSettingsViewModel.hotdTime)

        DispatchQueue.main.async {
            showWorshipFlow = true
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
    
    private func scheduleGreetingRefresh() {
        greetingTimer?.invalidate()

        let calendar = Calendar.current
        let now = Date()

        // Define daily boundaries at 06:00, 12:00, 18:00, 21:00
        let boundaryComponents: [DateComponents] = [
            DateComponents(hour: 6, minute: 0, second: 0),
            DateComponents(hour: 12, minute: 0, second: 0),
            DateComponents(hour: 18, minute: 0, second: 0),
            DateComponents(hour: 21, minute: 0, second: 0)
        ]

        // Find the next boundary after 'now'
        let nextBoundary = boundaryComponents
            .compactMap { calendar.nextDate(after: now, matching: $0, matchingPolicy: .nextTime) }
            .min(by: { $0 < $1 })

        guard let fireDate = nextBoundary else { return }
        let interval = fireDate.timeIntervalSince(now)

        greetingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            DispatchQueue.main.async {
                greetingTick.toggle()
                scheduleGreetingRefresh()
            }
        }
    }

    private func hotdGradientColors(for hymnID: Int) -> (Color, Color) {
        // Purposefully "premium" hues (muted in light mode, deeper in dark mode)
        switch abs(hymnID) % 5 {
        case 0:
            return (Color(red: 0.35, green: 0.50, blue: 0.88), Color(red: 0.20, green: 0.30, blue: 0.60)) // blue
        case 1:
            return (Color(red: 0.15, green: 0.62, blue: 0.46), Color(red: 0.10, green: 0.40, blue: 0.30)) // green
        case 2:
            return (Color(red: 0.78, green: 0.52, blue: 0.22), Color(red: 0.45, green: 0.28, blue: 0.10)) // gold
        case 3:
            return (Color(red: 0.55, green: 0.38, blue: 0.70), Color(red: 0.28, green: 0.18, blue: 0.42)) // purple
        default:
            return (Color(red: 0.28, green: 0.30, blue: 0.34), Color(red: 0.14, green: 0.15, blue: 0.18)) // graphite
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
        case let title where title.contains("child"):
            return "face.smiling"
        case let title where title.contains("warfare"):
            return "person.2.shield"
        default:
            return "book.closed"
        }
    }
}

