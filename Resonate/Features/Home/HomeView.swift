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

    private var devotionalIntro: String {
        switch greeting {
        case "Good Morning":
            return "Begin the day with worship, stillness, and a hymn that settles the heart."
        case "Good Afternoon":
            return "Return to a quiet place of worship in the middle of the day."
        case "Good Evening":
            return "Step into a gentler rhythm of reflection, gratitude, and song."
        default:
            return "Close the day with a hymn that keeps watch through the quiet hours."
        }
    }

    private var homeFocusCategories: [HymnCategory] {
        [
            .meditation_and_prayer,
            .hope_and_comfort,
            .morning_worship,
            .sabbath
        ].filter { environment.categoryViewModel.categories.contains($0) }
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
                .font(PremiumTheme.scaledSystem(size: 18, weight: .semibold))
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
        ZStack {
            PremiumScreenBackground()

            ScrollView {
                #if DEBUG
                Button {
    //                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    //                viewModel.refreshHymnOfTheDay(on: tomorrow)

                    let calendar = Calendar.current
                    let today = Date()

                    for offset in 0...5 {
                        if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                            viewModel.refreshHymnOfTheDay(on: date)
                            print("DAY +\(offset):", viewModel.hymnOfTheDay?.title ?? "nil")
                        }
                    }
                } label: {
                    Text("Refresh hymn of the day")
                }
                .buttonStyle(.plain)

                #endif


                content
            }
            .scrollIndicators(.hidden)
        }
        .miniPlayerInset(using: environment)
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
            DevotionalWelcomeHero
            DailyHymnHero
            ContinueSection
            StartHereSection
            ThemesSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 28)
        .animation(.easeInOut(duration: 0.6), value: viewModel.hymnOfTheDay?.id)
    }

    private var DevotionalWelcomeHero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        GreetingIcon()
                        Text(greeting)
                            .id(greetingTick)
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    }

                    Text("Begin Here")
                        .font(PremiumTheme.titleFont(size: 34))
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

                    Text(devotionalIntro)
                        .font(PremiumTheme.bodyFont())
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                Image(systemName: isHymnOfDayNotificationsOn ? "bell.badge.fill" : "bell.slash.fill")
                    .font(PremiumTheme.scaledSystem(size: 17, weight: .semibold))
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.primary.opacity(0.78))
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color.white.opacity(0.10) : PremiumTheme.subtleFill(for: colorScheme))
                    )
                    .overlay(
                        Circle().stroke(
                            colorScheme == .dark ? Color.white.opacity(0.20) : PremiumTheme.border(for: colorScheme),
                            lineWidth: 1
                        )
                    )
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.22 : 0.08), radius: 8, y: 4)
                    .accessibilityLabel(isHymnOfDayNotificationsOn ? "Notifications On" : "Notifications Off")
            }

            SearchSection

            if !homeFocusCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(homeFocusCategories, id: \.self) { category in
                            NavigationLink(value: category) {
                                HStack(spacing: 8) {
                                    Image(systemName: symbol(for: category))
                                        .font(.caption.weight(.semibold))
                                    Text(categoryChipTitle(for: category))
                                        .font(.subheadline.weight(.medium))
                                }
                                .foregroundStyle(colorScheme == .dark ? .white : PremiumTheme.primaryText(for: colorScheme))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(colorScheme == .dark ? Color.white.opacity(0.08) : PremiumTheme.subtleFill(for: colorScheme))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(colorScheme == .dark ? Color.white.opacity(0.10) : PremiumTheme.border(for: colorScheme), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark
                            ? [
                                Color.white.opacity(0.09),
                                Color.white.opacity(0.04)
                            ]
                            : [
                                Color(red: 0.99, green: 0.97, blue: 0.93),
                                Color(red: 0.94, green: 0.88, blue: 0.79)
                            ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: PremiumTheme.shadow(for: colorScheme), radius: 18, y: 10)
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
                    ZStack {
                        let cardShape = RoundedRectangle(cornerRadius: 26, style: .continuous)
                        let palette = hotdGradientColors(for: hymn.id)

                        DailyHymnCardBackground(cardShape: cardShape, palette: palette, colorScheme: colorScheme)

                        Circle()
                            .fill(Color.white.opacity(colorScheme == .dark ? 0.10 : 0.16))
                            .frame(width: 170, height: 170)
                            .blur(radius: 2)
                            .offset(x: 128, y: -92)
                            .allowsHitTesting(false)

                        Circle()
                            .fill(Color.black.opacity(colorScheme == .dark ? 0.18 : 0.08))
                            .frame(width: 220, height: 220)
                            .blur(radius: 18)
                            .offset(x: 110, y: 112)
                            .allowsHitTesting(false)

                        VStack(alignment: .leading, spacing: 18) {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Hymn for Today")
                                        .font(PremiumTheme.eyebrowFont())
                                        .textCase(.uppercase)
                                        .tracking(1.2)
                                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.82) : PremiumTheme.secondaryText(for: colorScheme))

                                    Text("#\(hymn.id)")
                                        .font(PremiumTheme.captionFont())
                                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.72) : PremiumTheme.secondaryText(for: colorScheme))
                                }

                                Spacer(minLength: 12)

                                hotdMetaPill(text: "Today", systemImage: "sparkles")
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text(hymn.title)
                                    .font(PremiumTheme.titleFont(size: 25))
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.96) : PremiumTheme.primaryText(for: colorScheme))
                                    .lineSpacing(2)
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text(hotdInvitation(for: hymn))
                                    .font(PremiumTheme.bodyFont())
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.88) : PremiumTheme.primaryText(for: colorScheme).opacity(0.84))
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    hotdMetaPill(text: hymn.category.title, systemImage: "tag.fill")
                                    hotdMetaPill(text: hotdMomentLabel(for: hymn), systemImage: "sparkles")
                                }
                                .padding(.vertical, 1)
                            }

                            HStack(spacing: 10) {
                                Button {
                                    environment.analyticsService.log(
                                        .tabSwitched,
                                        parameters: [
                                            .source: "home",
                                            .destination: "worship_flow_from_hotd_begin_button"
                                        ]
                                    )
                                    showWorshipFlow = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "play.fill")
                                            .font(PremiumTheme.scaledSystem(size: 12, weight: .bold))
                                        Text("Begin")
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        colorScheme == .dark
                                            ? Color.white.opacity(0.16)
                                            : Color.white.opacity(0.74)
                                    )
                                    .overlay(
                                        Capsule().stroke(
                                            colorScheme == .dark ? Color.white.opacity(0.14) : Color.black.opacity(0.06),
                                            lineWidth: 1
                                        )
                                    )
                                    .clipShape(Capsule())
                                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black.opacity(0.84))
                                }
                                .buttonStyle(.plain)

                                hotdReminderButton
                            }
                        }
                        .padding(22)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity, minHeight: 252)
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

    private var hotdReminderButton: some View {
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
                        Image(systemName: "bell.badge")
                            .font(PremiumTheme.scaledSystem(size: 12, weight: .semibold))
                        Text("Remind Me")
                            .font(.subheadline.weight(.semibold))
                    }
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
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "bell.badge.waveform")
                        .font(PremiumTheme.scaledSystem(size: 12, weight: .semibold))
                    Text("Reminder On")
                        .font(.subheadline.weight(.semibold))
                }
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
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Daily hymn reminder is enabled")
            }
        }
    }

    private func hotdInvitation(for hymn: HymnIndex) -> String {
        let title = hymn.category.title.lowercased()
        if title.contains("comfort") || title.contains("hope") {
            return "For steadiness, courage, and quiet trust today."
        } else if title.contains("prayer") || title.contains("meditation") {
            return "For stillness, listening, and a more prayerful pace."
        } else if title.contains("morning") {
            return "For a brighter beginning and a gentler first offering."
        } else if title.contains("evening") {
            return "For gratitude, reflection, and rest at day’s end."
        } else if title.contains("sabbath") {
            return "For holy rest and a heart gathered back to worship."
        } else if title.contains("praise") || title.contains("adoration") {
            return "For reverence, joy, and a heart lifted in worship."
        } else {
            return "For worship, reflection, and a hymn worthy of returning to."
        }
    }

    private func hotdMomentLabel(for hymn: HymnIndex) -> String {
        let title = hymn.category.title.lowercased()
        if title.contains("morning") {
            return "Morning"
        } else if title.contains("evening") {
            return "Evening"
        } else if title.contains("sabbath") {
            return "Sabbath"
        } else if title.contains("prayer") {
            return "Prayer"
        } else if title.contains("comfort") || title.contains("hope") {
            return "Comfort"
        } else {
            return "Worship"
        }
    }

    private func hotdMetaPill(text: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
            Text(text)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.thinMaterial)
        .overlay(
            Capsule().stroke(
                colorScheme == .dark ? Color.white.opacity(0.14) : Color.black.opacity(0.06),
                lineWidth: 1
            )
        )
        .clipShape(Capsule())
        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.88) : .primary)
    }

    private struct DailyHymnCardBackground: View {
        let cardShape: RoundedRectangle
        let palette: (Color, Color)
        let colorScheme: ColorScheme

        private var baseFillGradient: some ShapeStyle {
            LinearGradient(
                colors: [
                    palette.0.opacity(colorScheme == .dark ? 0.90 : 0.38),
                    palette.1.opacity(colorScheme == .dark ? 0.75 : 0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        private var topHighlightFill: some ShapeStyle {
            RadialGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.10 : 0.12),
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
                    Color.black.opacity(colorScheme == .dark ? 0.55 : 0.10),
                    Color.clear
                ],
                center: .bottom,
                startRadius: 40,
                endRadius: 320
            )
        }

        private var warmLightWash: some ShapeStyle {
            LinearGradient(
                colors: [
                    Color(red: 0.93, green: 0.89, blue: 0.82).opacity(0.92),
                    Color(red: 0.84, green: 0.79, blue: 0.72).opacity(0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
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

            let lightWash: AnyView = {
                if colorScheme == .light {
                    return AnyView(
                        cardShape
                            .fill(warmLightWash)
                            .blendMode(.softLight)
                            .allowsHitTesting(false)
                    )
                } else {
                    return AnyView(EmptyView())
                }
            }()

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
                .overlay(lightWash)
                .overlay(bottomVignette)
                .overlay(darkGlass)
                .overlay(primaryStroke)
                .overlay(secondaryStroke)
                .overlay(watermark, alignment: .topTrailing)
        }
    }

    private var ContinueSection: some View {
        Group {
            if !viewModel.recentlyViewed.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    sectionEyebrow("Return to These")

                    Text("Continue Your Reflection")
                        .font(PremiumTheme.sectionTitleFont())
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

                    Text("Pick up where a hymn last met you.")
                        .font(PremiumTheme.bodyFont())
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))

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
        }
    }

    private var StartHereSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 12) {
                if isEarlyUser {
                    sectionEyebrow("New Here?")
                }

                Text("For This Moment")
                    .font(.title3.weight(.semibold))

                Text("A few gentle ways to begin worship, reflection, and discovery.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

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
                            title: "Beloved",
                            subtitle: "Return to favorites",
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
                            title: "Editor’s",
                            subtitle: "Curated to begin",
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
                                title: "Today’s Hymn",
                                subtitle: "Stay close today",
                                systemImage: "sparkles"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(22)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 30)
    }

    private var ThemesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    sectionEyebrow("Paths")
                    Text("For This Need")
                        .font(PremiumTheme.sectionTitleFont())
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                    Text("Move toward comfort, prayer, hope, and worship through curated themes.")
                        .font(PremiumTheme.scaledSystem(size: 16, weight: .medium))
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                }

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
                .font(PremiumTheme.captionFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(environment.categoryViewModel.categories.prefix(6)) { category in
                        NavigationLink(value: category) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("\(environment.categoryViewModel.hymns(for: category).count) hymns")
                                            .font(PremiumTheme.captionFont())
                                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))

                                        Text(pathDescriptor(for: category))
                                            .font(PremiumTheme.scaledSystem(size: 11, weight: .bold))
                                            .textCase(.uppercase)
                                            .tracking(1.0)
                                            .foregroundStyle(pathAccent(for: category))
                                    }

                                    Spacer(minLength: 8)

                                    Image(systemName: symbol(for: category))
                                        .font(PremiumTheme.scaledSystem(size: 18, weight: .semibold))
                                        .foregroundStyle(pathAccent(for: category))
                                        .frame(width: 36, height: 36)
                                        .background(
                                            Circle()
                                                .fill(pathAccent(for: category).opacity(colorScheme == .dark ? 0.18 : 0.12))
                                        )
                                }

                                Spacer()

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(category.title)
                                        .font(PremiumTheme.scaledSystem(size: 20, weight: .semibold, design: .serif))
                                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)

                                    Text(pathSubtitle(for: category))
                                        .font(PremiumTheme.scaledSystem(size: 14, weight: .medium))
                                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                                        .lineLimit(2)
                                }
                            }
                            .padding(20)
                            .frame(width: 196, height: 168, alignment: .topLeading)
                            .background {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(PremiumTheme.panelFill(for: colorScheme))
                                    .overlay(alignment: .topTrailing) {
                                        Circle()
                                            .fill(pathAccent(for: category).opacity(colorScheme == .dark ? 0.14 : 0.10))
                                            .frame(width: 130, height: 130)
                                            .blur(radius: 10)
                                            .offset(x: 36, y: -34)
                                    }
                                    .overlay(alignment: .bottomTrailing) {
                                        Image(systemName: symbol(for: category))
                                            .font(PremiumTheme.scaledSystem(size: 82, weight: .regular))
                                            .foregroundStyle(pathAccent(for: category).opacity(colorScheme == .dark ? 0.10 : 0.08))
                                            .offset(x: 16, y: 8)
                                    }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                            )
                            .shadow(
                                color: PremiumTheme.shadow(for: colorScheme).opacity(0.72),
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

    private func sectionEyebrow(_ text: String) -> some View {
        Text(text)
            .font(PremiumTheme.eyebrowFont())
            .foregroundStyle(PremiumTheme.accent(for: colorScheme))
            .textCase(.uppercase)
            .tracking(1.3)
    }

    private func categoryChipTitle(for category: HymnCategory) -> String {
        switch category {
        case .meditation_and_prayer: return "Prayer"
        case .hope_and_comfort: return "Comfort"
        case .morning_worship: return "Morning"
        case .sabbath: return "Sabbath"
        default: return category.title
        }
    }

    private func pathDescriptor(for category: HymnCategory) -> String {
        switch category {
        case .meditation_and_prayer: return "Stillness"
        case .hope_and_comfort: return "Comfort"
        case .morning_worship: return "Morning"
        case .sabbath: return "Sacred Rest"
        case .adoration_and_praise, .opening_of_worship, .close_of_worship, .glory_and_praise:
            return "Worship"
        default:
            return "Curated Path"
        }
    }

    private func pathSubtitle(for category: HymnCategory) -> String {
        switch category {
        case .meditation_and_prayer:
            return "Move gently into prayer and reflection."
        case .hope_and_comfort:
            return "Songs for steadiness, peace, and reassurance."
        case .morning_worship:
            return "Begin the day with clarity and praise."
        case .sabbath:
            return "Enter holy rest with hymns shaped for Sabbath."
        case .adoration_and_praise, .opening_of_worship, .close_of_worship, .glory_and_praise:
            return "Gather the heart toward praise and reverence."
        default:
            return "Explore a thoughtful route through worship."
        }
    }

    private func pathAccent(for category: HymnCategory) -> Color {
        let base = abs(category.id.hashValue)
        if colorScheme == .dark {
            switch base % 4 {
            case 0: return Color(red: 0.74, green: 0.66, blue: 0.45)
            case 1: return Color(red: 0.56, green: 0.69, blue: 0.60)
            case 2: return Color(red: 0.67, green: 0.63, blue: 0.78)
            default: return Color(red: 0.60, green: 0.68, blue: 0.80)
            }
        }

        switch base % 4 {
        case 0: return Color(red: 0.69, green: 0.53, blue: 0.31)
        case 1: return Color(red: 0.41, green: 0.56, blue: 0.45)
        case 2: return Color(red: 0.57, green: 0.48, blue: 0.67)
        default: return Color(red: 0.49, green: 0.58, blue: 0.72)
        }
    }

    // Light Mode: premium solid card. Dark Mode: glass card.
    private func startHereCard(title: String, subtitle: String, systemImage: String) -> some View {
        Group {
            if colorScheme == .dark {
                // Glass card style (dark mode)
                HStack(alignment: .top, spacing: 14) {
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
                            .font(PremiumTheme.scaledSystem(size: 17, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(PremiumTheme.accent(for: colorScheme))
                    }
                    .frame(width: 42, height: 42)
                    .shadow(color: Color.black.opacity(0.10), radius: 10, y: 6)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(PremiumTheme.scaledSystem(size: 18, weight: .semibold, design: .serif))
                            .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                            .lineLimit(1)

                        Text(subtitle)
                            .font(PremiumTheme.scaledSystem(size: 14, weight: .medium))
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(PremiumTheme.scaledSystem(size: 13, weight: .semibold))
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
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
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        PremiumTheme.accent(for: colorScheme).opacity(0.95),
                                        PremiumTheme.accent(for: colorScheme).opacity(0.60)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Image(systemName: systemImage)
                            .font(PremiumTheme.scaledSystem(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 42, height: 42)
                    .shadow(color: Color.black.opacity(0.10), radius: 6, y: 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(PremiumTheme.scaledSystem(size: 18, weight: .semibold, design: .serif))
                            .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                            .lineLimit(1)

                        Text(subtitle)
                            .font(PremiumTheme.scaledSystem(size: 14, weight: .medium))
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(PremiumTheme.scaledSystem(size: 13, weight: .semibold))
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(PremiumTheme.subtleFill(for: colorScheme))
                        )
                        .overlay(
                            Circle()
                                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                        )
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.99, green: 0.97, blue: 0.94),
                                    Color(red: 0.95, green: 0.90, blue: 0.82)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(PremiumTheme.border(for: colorScheme))
                )
                .shadow(color: PremiumTheme.shadow(for: colorScheme), radius: 12, y: 7)
            }
        }
        .padding(22)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 30)
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

//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        formatter.dateStyle = .none
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
