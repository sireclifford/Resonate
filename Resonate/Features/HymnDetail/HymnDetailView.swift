import SwiftUI

struct HymnDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let environment: AppEnvironment
    let source: String
    @ObservedObject private var settings: AppSettingsService
    @StateObject private var viewModel: HymnDetailViewModel
    @ObservedObject private var favouritesService: FavouritesService
    @ObservedObject private var accompanimentPlaybackService: AccompanimentPlaybackService
    
    @State private var showStory = false
    @State private var viewStart: Date?
    @State private var counted = false
    @State private var storyViewStart: Date?
    
    let index: HymnIndex
    
    init(index: HymnIndex, environment: AppEnvironment, source: String = "direct") {
        self.index = index
        self.environment = environment
        self.source = source
        _settings = ObservedObject(wrappedValue: environment.settingsService)
        _viewModel = StateObject(
            wrappedValue: HymnDetailViewModel(
                index: index,
                hymnService: environment.hymnService
            )
        )
        _favouritesService = ObservedObject(
            wrappedValue: environment.favouritesService
        )
        _accompanimentPlaybackService = ObservedObject(
            wrappedValue: environment.accompanimentPlaybackService
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Top bar
            ReaderTopBar(
                index: viewModel.hymn,
                verseCount: viewModel.detail?.verses.count ?? 0,
                availableLanguages: viewModel.availableLanguages,
                selectedLanguage: viewModel.selectedLanguage,
                onLanguageSelect: { viewModel.selectedLanguage = $0 },
                fontSize: settings.fontSize,
                onFontSelect: { settings.fontSize = $0 },
                isFavourite: favouritesService.isFavourite(id: viewModel.hymn.id),
                onFavouriteToggle: {
                    favouritesService.toggle(id: viewModel.hymn.id)
                }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    devotionalHeader
                    accompanimentActionRow
                    lyricsCanvas
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
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
            )
            
            ReaderBottomBar(
                audioPlaybackService: accompanimentPlaybackService,
                hymnID: viewModel.hymn.id,
                hasNext: viewModel.hasNext,
                hasPrevious: viewModel.hasPrevious,
                onPrevious: {
                    accompanimentPlaybackService.stop()
                    viewModel.previousHymn()
                },
                onPlayToggle: {
                    accompanimentPlaybackService.togglePlayback(for: viewModel.hymn.id)
                },
                onNext: {
                    accompanimentPlaybackService.stop()
                    viewModel.nextHymn()
                }
            )
        }
        .navigationTitle(viewModel.hymn.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showStory, onDismiss: {
            if let start = storyViewStart {
                let seconds = Int(Date().timeIntervalSince(start).rounded())
                environment.analyticsService.storyClosed(hymnID: viewModel.hymn.id, durationSeconds: seconds)
                storyViewStart = nil
            }
        }){
            NavigationStack {
                if let story = environment.hymnStoryService.story(for: viewModel.hymn.id) {
                    HymnStoryView(
                        story: story
                    )
                    .environmentObject(environment)
                    .onAppear {
                        storyViewStart = Date()
                        environment.analyticsService.storyOpened(hymnID: viewModel.hymn.id)
                    }
                } else {
                    StoryUnavailableView()
                        .onAppear {
                            storyViewStart = Date()
                            environment.analyticsService.storyUnavailable(hymnID: viewModel.hymn.id)
                        }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            environment.activeHymnDetailID = viewModel.hymn.id
            environment.analyticsService.hymnOpened(
                id: viewModel.hymn.id,
                category: viewModel.hymn.category.rawValue,
                source: source
            )
//            
//            if let hotd = environment.hymnService.hymnOfTheDay(),
//               viewModel.hymn.id == hotd.id {
//                environment.hymnOfTheDayEngagementService.markOpened(hymnID: viewModel.hymn.id)
//#if DEBUG
//                print("MARK OPENED: id=\(viewModel.hymn.id) at \(Date())")
//                if let storedID: Int = environment.persistenceService.load(Int.self, for: "last_opened_hymn_id"),
//                   let storedDate: Date = environment.persistenceService.load(Date.self, for: "last_opened_hymn_date") {
//                    print("PERSISTED: id=\(storedID), date=\(storedDate)")
//                } else {
//                    print("PERSISTED: missing values")
//                }
//#endif
//            }
            
            viewStart = Date()
        }
        .onDisappear {
            if environment.activeHymnDetailID == viewModel.hymn.id {
                environment.activeHymnDetailID = nil
            }
            if settings.stopPlaybackOnExit {
                accompanimentPlaybackService.stop()
            }
            
            let dwellSeconds = viewStart.map { Int(Date().timeIntervalSince($0).rounded()) } ?? 0
            environment.analyticsService.hymnClosed(hymnID: viewModel.hymn.id, durationSeconds: dwellSeconds)
            
            guard let start = viewStart,
                  Date().timeIntervalSince(start) >= 10,
                  !counted
            else { return }
            
            environment.sessionService.markInteraction()
            environment.usageService.increment(viewModel.hymn.id)
            environment.recentlyViewedService.record(id: viewModel.hymn.id)
            counted = true
            environment.recentSearchService.add(viewModel.hymn.id)
        }
    }

    private var devotionalHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hymn \(viewModel.hymn.id)")
                        .font(.caption.weight(.semibold))
                        .textCase(.uppercase)
                        .tracking(0.8)
                        .foregroundStyle(.secondary)

                    Text(viewModel.hymn.title)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        detailPill(text: viewModel.hymn.category.title, icon: "tag.fill")
                        detailPill(text: "\(viewModel.detail?.verses.count ?? 0) verses", icon: "text.justify")
                    }
                }

                Spacer(minLength: 12)

                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.44))
                            .frame(width: 64, height: 64)

                        Image(systemName: detailSymbol)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.primary)
                    }

                    storyButton
                }
            }

            if let devotionalContext {
                VStack(alignment: .leading, spacing: 10) {
                    Text(devotionalContext.title)
                        .font(.caption.weight(.semibold))
                        .textCase(.uppercase)
                        .tracking(0.7)
                        .foregroundStyle(.secondary)

                    Text(devotionalContext.body)
                        .font(.system(size: 17, weight: .medium, design: .serif))
                        .foregroundStyle(.primary.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.06), lineWidth: 1)
                )
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark
                            ? [
                                Color(red: 0.19, green: 0.18, blue: 0.20),
                                Color(red: 0.12, green: 0.12, blue: 0.14)
                            ]
                            : [
                                Color(red: 0.95, green: 0.93, blue: 0.88),
                                Color(red: 0.90, green: 0.88, blue: 0.82)
                            ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.24 : 0.06), radius: 18, y: 10)
    }

    private var lyricsCanvas: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Lyrics")
                    .font(.title3.weight(.semibold))

                Text("Read slowly, sing freely, and linger where the words ask you to.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 24) {
                ForEach(viewModel.versesForSelectedLanguage.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 18) {
                        VerseView(
                            title: "\(index + 1).",
                            lines: viewModel.versesForSelectedLanguage[index],
                            fontSize: settings.fontSize,
                            fontFamily: settings.fontFamily,
                            lineSpacing: settings.lineSpacing,
                            showVerseNumbers: settings.showVerseNumbers
                        )

                        if let chorus = viewModel.detail?.chorus, settings.chorusLabelStyle != .hide {
                            ChorusView(
                                title: settings.chorusLabelStyle.label,
                                lines: chorus,
                                fontFamily: settings.fontFamily,
                                fontSize: settings.fontSize,
                                lineSpacing: settings.lineSpacing,
                            )
                        }
                    }

                    if index < viewModel.versesForSelectedLanguage.indices.last ?? 0 {
                        Rectangle()
                            .fill(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.06))
                            .frame(height: 1)
                    }
                }
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.18 : 0.04), radius: 14, y: 8)
        }
    }

    private var storyButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showStory = true
        } label: {
            Image(systemName: "book.pages")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.44))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.05), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var devotionalContext: (title: String, body: String)? {
        if let highlight = viewModel.detail?.highlight, !highlight.isEmpty {
            return ("Reflection", highlight)
        }

        if let scriptureRef = viewModel.detail?.scriptureRef, !scriptureRef.isEmpty {
            return ("Scripture", scriptureRef)
        }

        if let reflection = viewModel.detail?.reflection, !reflection.isEmpty {
            return ("Meditation", reflection)
        }

        return nil
    }

    private var detailSymbol: String {
        let title = viewModel.hymn.category.title.lowercased()
        if title.contains("praise") || title.contains("adoration") {
            return "hands.clap.fill"
        } else if title.contains("prayer") || title.contains("meditation") {
            return "hands.sparkles.fill"
        } else if title.contains("comfort") || title.contains("hope") {
            return "heart.text.square.fill"
        } else if title.contains("morning") {
            return "sunrise.fill"
        } else if title.contains("evening") {
            return "moon.stars.fill"
        } else if title.contains("sabbath") {
            return "sun.max.fill"
        } else {
            return "music.note"
        }
    }

    private func detailPill(text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
            Text(text)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.44))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.05), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var accompanimentActionRow: some View {
        let hymnID = viewModel.hymn.id
        let fileState = accompanimentPlaybackService.fileState(for: hymnID)
        
        HStack(spacing: 12) {
            switch fileState {
            case .downloaded:
                Label("Downloaded", systemImage: "arrow.down.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
                
                Spacer()
                
                Button("Delete") {
                    accompanimentPlaybackService.deleteDownload(for: hymnID)
                }
                .font(.subheadline.weight(.semibold))
                
            case .downloading:
                ProgressView()
                    .progressViewStyle(.circular)
                
                Text("Downloading accompaniment…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
            case .remoteOnly:
                Label("Available online", systemImage: "icloud.and.arrow.down")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("Download") {
                    Task {
                        await accompanimentPlaybackService.download(for: hymnID)
                    }
                }
                .font(.subheadline.weight(.semibold))
                
            case .unavailable:
                Label("Accompaniment unavailable", systemImage: "speaker.slash")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("Retry") {
                    Task {
                        await accompanimentPlaybackService.download(for: hymnID)
                    }
                }
                .font(.subheadline.weight(.semibold))
                
            case .failed(let message):
                VStack(alignment: .leading, spacing: 4) {
                    Label("Accompaniment unavailable", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.orange)
                    
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button("Retry") {
                    Task {
                        await accompanimentPlaybackService.download(for: hymnID)
                    }
                }
                .font(.subheadline.weight(.semibold))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.06), lineWidth: 1)
        )
    }
}
