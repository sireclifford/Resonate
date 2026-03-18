import SwiftUI

struct FavouritesView: View {
    @Environment(\.colorScheme) private var colorScheme

    let environment: AppEnvironment
    @StateObject private var viewModel: FavouritesViewModel
    @ObservedObject private var audioService: AudioPlaybackService
    @State private var selectedLens: DevotionalLens = .all
    @State private var recentlyRemoved: HymnIndex?
    @State private var showUndoToast = false

    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = StateObject(
            wrappedValue: FavouritesViewModel(
                hymnService: environment.hymnService,
                favouritesService: environment.favouritesService
            )
        )

        _audioService = ObservedObject(
            wrappedValue: environment.audioPlaybackService
        )
    }

    private var visibleLenses: [DevotionalLens] {
        let available = Set(viewModel.hymns.flatMap { devotionalLenses(for: $0) })
        let ordered = DevotionalLens.allCases.filter { $0 == .all || available.contains($0) }
        return ordered
    }

    private var filteredHymns: [HymnIndex] {
        guard selectedLens != .all else { return viewModel.hymns }
        return viewModel.hymns.filter { devotionalLenses(for: $0).contains(selectedLens) }
    }

    private var featuredHymn: HymnIndex? {
        filteredHymns.first
    }

    private var remainingHymns: [HymnIndex] {
        Array(filteredHymns.dropFirst())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                hero

                if viewModel.hymns.isEmpty {
                    emptyState
                } else {
                    lensPicker

                    if let featuredHymn {
                        sectionTitle("Featured Return")
                        featuredCard(hymn: featuredHymn)
                    }

                    if !remainingHymns.isEmpty {
                        sectionTitle(selectedLens == .all ? "Saved Hymns" : "\(selectedLens.title) Collection")

                        LazyVStack(spacing: 14) {
                            ForEach(remainingHymns) { hymn in
                                savedHymnCard(hymn: hymn)
                            }
                        }
                    } else if filteredHymns.isEmpty {
                        filteredEmptyState
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground),
                    Color(.secondarySystemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Favourites")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if showUndoToast, let removed = recentlyRemoved {
                undoToast(for: removed)
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Devotional Library")
                        .font(.system(size: 31, weight: .bold, design: .serif))

                    Text("Hymns you return to for comfort, worship, reflection, and quiet strength.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.78, green: 0.61, blue: 0.34).opacity(colorScheme == .dark ? 0.28 : 0.24),
                                    Color(red: 0.46, green: 0.31, blue: 0.18).opacity(colorScheme == .dark ? 0.18 : 0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 58, height: 58)

                    Image(systemName: "heart.text.square")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }

            HStack(spacing: 12) {
                heroMetric(
                    title: "Saved",
                    value: "\(viewModel.hymns.count)",
                    icon: "heart.fill"
                )
                heroMetric(
                    title: "Focus",
                    value: selectedLens.title,
                    icon: selectedLens.icon
                )
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark
                            ? [
                                Color(red: 0.19, green: 0.18, blue: 0.20),
                                Color(red: 0.12, green: 0.12, blue: 0.14)
                            ]
                            : [
                                Color(red: 0.99, green: 0.97, blue: 0.92),
                                Color(red: 0.95, green: 0.92, blue: 0.86)
                            ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.26 : 0.06), radius: 18, y: 10)
    }

    private var lensPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(visibleLenses) { lens in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            selectedLens = lens
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: lens.icon)
                                .font(.caption.weight(.semibold))
                            Text(lens.title)
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(selectedLens == lens ? Color.white : Color.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedLens == lens ? Color.accentColor : Color(.secondarySystemBackground))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.primary.opacity(selectedLens == lens ? 0 : 0.06), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func featuredCard(hymn: HymnIndex) -> some View {
        NavigationLink {
            HymnDetailView(
                index: hymn,
                environment: environment,
                source: "favourites_featured"
            )
        } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: featuredPalette(for: hymn),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(colorScheme == .dark ? 0.18 : 0.14)

                Circle()
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.16))
                    .frame(width: 180, height: 180)
                    .offset(x: 60, y: -70)

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(devotionalDescriptor(for: hymn))
                                .font(.caption.weight(.semibold))
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)

                            Text(hymn.title)
                                .font(.system(size: 26, weight: .bold, design: .serif))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                        }

                        Spacer(minLength: 12)

                        removeButton(for: hymn, compact: false)
                    }

                    Text(reflectionPrompt(for: hymn))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    ViewThatFits(in: .vertical) {
                        HStack(spacing: 10) {
                            featurePill(text: "Hymn \(hymn.id)", icon: "music.note")
                            featurePill(
                                text: hymn.category.title,
                                icon: devotionalLenses(for: hymn).first?.icon ?? "sparkles"
                            )
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            featurePill(text: "Hymn \(hymn.id)", icon: "music.note")
                            featurePill(
                                text: hymn.category.title,
                                icon: devotionalLenses(for: hymn).first?.icon ?? "sparkles"
                            )
                        }
                    }

                    HStack(spacing: 12) {
                        actionCapsule(title: "Read", icon: "book.closed")
                        if audioService.currentHymnID == hymn.id {
                            actionCapsule(title: "Playing", icon: "speaker.wave.2.fill")
                        } else {
                            actionCapsule(title: "Play", icon: "play.fill")
                        }
                    }
                }
                .padding(22)
            }
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.26 : 0.08), radius: 20, y: 12)
        }
        .buttonStyle(.plain)
    }

    private func savedHymnCard(hymn: HymnIndex) -> some View {
        NavigationLink {
            HymnDetailView(
                index: hymn,
                environment: environment,
                source: "favourites_list"
            )
        } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.accentColor.opacity(0.10))
                        .frame(width: 56, height: 56)

                    VStack(spacing: 1) {
                        Text("Hymn")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text("\(hymn.id)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(hymn.title)
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Text(reflectionPrompt(for: hymn))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        ForEach(Array(devotionalLenses(for: hymn).prefix(2)), id: \.self) { lens in
                            miniPill(text: lens.title)
                        }
                    }
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 12) {
                    removeButton(for: hymn, compact: true)

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.18 : 0.04), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("Begin Here")

            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: "heart")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(.secondary)

                Text("Build your devotional library")
                    .font(.title3.weight(.semibold))

                Text("Save hymns that steady your heart, shape your worship, and stay with you through the week.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 8) {
                    emptySuggestion(title: "Morning Worship", subtitle: "Begin the day with adoration and quiet focus")
                    emptySuggestion(title: "Hope and Comfort", subtitle: "Return here in seasons of grief or uncertainty")
                    emptySuggestion(title: "Meditation and Prayer", subtitle: "Keep reflective hymns close at hand")
                }
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }

    private var filteredEmptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No saved hymns in \(selectedLens.title.lowercased()) yet.")
                .font(.headline)
            Text("Try another devotional lens or save a hymn that fits this season.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func heroMetric(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(colorScheme == .dark ? .white : .primary)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(colorScheme == .dark ? .white : .primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.52))
        )
        .overlay(
            Capsule()
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.05), lineWidth: 1)
        )
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func featurePill(text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.46))
        .clipShape(Capsule())
        .fixedSize(horizontal: true, vertical: false)
    }

    private func actionCapsule(title: String, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.42))
        .clipShape(Capsule())
    }

    private func miniPill(text: String) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())
    }

    private func emptySuggestion(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    private func removeButton(for hymn: HymnIndex, compact: Bool) -> some View {
        Button {
            remove(hymn)
        } label: {
            Image(systemName: "heart.fill")
                .font(.system(size: compact ? 14 : 15, weight: .semibold))
                .foregroundStyle(Color.red)
                .frame(width: compact ? 34 : 38, height: compact ? 34 : 38)
                .background(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.64))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private func undoToast(for hymn: HymnIndex) -> some View {
        HStack {
            Text("Removed \(hymn.title)")
                .font(.subheadline)
                .foregroundStyle(.white)

            Spacer()

            Button("Undo") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    environment.favouritesService.toggle(id: hymn.id)
                }
                showUndoToast = false
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
        }
        .padding()
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showUndoToast = false
                }
            }
        }
    }

    private func remove(_ hymn: HymnIndex) {
        withAnimation(.easeInOut(duration: 0.25)) {
            environment.favouritesService.toggle(id: hymn.id)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        recentlyRemoved = hymn
        showUndoToast = true
    }

    private func reflectionPrompt(for hymn: HymnIndex) -> String {
        switch devotionalLenses(for: hymn).first ?? .all {
        case .worship:
            return "Return to this hymn when you want to re-center your worship."
        case .comfort:
            return "Keep this nearby for anxious or weary moments."
        case .hope:
            return "A hymn to revisit when you need perspective and promise."
        case .prayer:
            return "Well suited for slower reflection and personal prayer."
        case .morning:
            return "A fitting companion for the first quiet moments of the day."
        case .evening:
            return "Best revisited when the day is winding down."
        case .all:
            return "A hymn worth keeping close in your devotional rhythm."
        }
    }

    private func devotionalDescriptor(for hymn: HymnIndex) -> String {
        switch devotionalLenses(for: hymn).first ?? .all {
        case .worship: return "For worship and adoration"
        case .comfort: return "For comfort and rest"
        case .hope: return "For hope and expectation"
        case .prayer: return "For prayer and reflection"
        case .morning: return "For morning devotion"
        case .evening: return "For evening stillness"
        case .all: return "For your devotional library"
        }
    }

    private func featuredPalette(for hymn: HymnIndex) -> [Color] {
        switch devotionalLenses(for: hymn).first ?? .all {
        case .worship:
            return [Color(red: 0.80, green: 0.67, blue: 0.40), Color(red: 0.47, green: 0.34, blue: 0.18)]
        case .comfort:
            return [Color(red: 0.52, green: 0.61, blue: 0.76), Color(red: 0.28, green: 0.34, blue: 0.49)]
        case .hope:
            return [Color(red: 0.63, green: 0.56, blue: 0.79), Color(red: 0.34, green: 0.27, blue: 0.48)]
        case .prayer:
            return [Color(red: 0.44, green: 0.63, blue: 0.55), Color(red: 0.22, green: 0.35, blue: 0.29)]
        case .morning:
            return [Color(red: 0.92, green: 0.74, blue: 0.46), Color(red: 0.68, green: 0.47, blue: 0.22)]
        case .evening:
            return [Color(red: 0.36, green: 0.43, blue: 0.62), Color(red: 0.20, green: 0.24, blue: 0.36)]
        case .all:
            return [Color(red: 0.69, green: 0.60, blue: 0.46), Color(red: 0.42, green: 0.33, blue: 0.24)]
        }
    }

    private func devotionalLenses(for hymn: HymnIndex) -> [DevotionalLens] {
        switch hymn.category {
        case .adoration_and_praise, .opening_of_worship, .close_of_worship, .glory_and_praise, .call_to_worship, .love_of_god, .majesty_and_power_of_god, .faithfulness_of_god, .our_love_for_god, .love_of_christ_for_us:
            return [.worship]
        case .hope_and_comfort, .eternal_life, .joy_and_peace, .faith_and_trust, .guidance, .health_and_wholeness:
            return [.comfort, .hope]
        case .meditation_and_prayer, .repentance, .forgiveness, .consecration, .humility, .communion:
            return [.prayer]
        case .morning_worship:
            return [.morning, .worship]
        case .sda_hymnal_evening_worship:
            return [.evening, .comfort]
        case .second_advent, .sda_hymnal_early_advent, .resurrection_of_the_saints, .sda_hymnal_kingdom_and_reign:
            return [.hope]
        default:
            return [.all]
        }
    }
}

private enum DevotionalLens: String, CaseIterable, Identifiable {
    case all
    case worship
    case comfort
    case hope
    case prayer
    case morning
    case evening

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .worship: return "Worship"
        case .comfort: return "Comfort"
        case .hope: return "Hope"
        case .prayer: return "Prayer"
        case .morning: return "Morning"
        case .evening: return "Evening"
        }
    }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .worship: return "sparkles"
        case .comfort: return "hands.and.sparkles"
        case .hope: return "sunrise"
        case .prayer: return "hands.sparkles"
        case .morning: return "sun.max"
        case .evening: return "moon.stars"
        }
    }
}
