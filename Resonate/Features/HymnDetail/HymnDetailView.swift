import SwiftUI

struct HymnDetailView: View {
    
    let environment: AppEnvironment
    let source: String
    @ObservedObject private var settings: AppSettingsService
    @StateObject private var viewModel: HymnDetailViewModel
    @ObservedObject private var favouritesService: FavouritesService
    
    @State private var showStory = false
    @State private var viewStart: Date?
    @State private var counted = false
    @State private var showNotificationPrompt = false
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
            
            
            Divider()
            
            // Lyrics only scroll
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    ForEach(viewModel.versesForSelectedLanguage.indices, id: \.self) { index in
                        VerseView(
                            title: "\(index + 1).",
                            lines: viewModel.versesForSelectedLanguage[index],
                            fontSize: settings.fontSize,
                            fontFamily: settings.fontFamily,
                            lineSpacing: settings.lineSpacing,
                            showVerseNumbers: settings.showVerseNumbers
                        )
                        
                        if let chorus = viewModel.detail?.chorus {
                            if settings.chorusLabelStyle != .hide {
                                ChorusView(
                                    title: settings.chorusLabelStyle.label,
                                    lines: chorus,
                                    fontFamily: settings.fontFamily,
                                    fontSize: settings.fontSize,
                                    lineSpacing: settings.lineSpacing,
                                )
                            }
                        }
                    }
                    
                }
                .padding()
            }
            
            // Bottom bar
            ReaderBottomBar(
                audioPlaybackService: environment.audioPlaybackService,
                canPlay: environment.tuneService.tuneExists(for: viewModel.hymn.id),
                hasNext: viewModel.hasNext,
                hasPrevious: viewModel.hasPrevious,
                onPrevious: {
                    environment.audioPlaybackService.stop()
                    viewModel.previousHymn()
                },
                onPlayToggle: {
                    environment.audioPlaybackService.togglePlayback(for: viewModel.hymn.id,
                                                                    tuneService: environment.tuneService
                    )
                },
                onNext: {
                    environment.audioPlaybackService.stop()
                    viewModel.nextHymn()
                }
            )
        }
        .navigationTitle(viewModel.hymn.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showStory = true
                } label: {
                    Image(systemName: "book.pages")
                }
            }
        }
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
        .sheet(isPresented: $showNotificationPrompt){
            VStack {
                    Text("Receive a Daily Hymn?")
                    Text("Begin each day with reflection.")

                    Button("Yes, Remind Me") {
                        environment.analyticsService.log(.notificationPromptAccepted, parameters: nil)
                        environment.notificationService.requestPermission()
                        showNotificationPrompt = false
                    }

                    Button("Not Now") {
                        environment.analyticsService.log(.notificationPromptDeclined, parameters: nil)
                        showNotificationPrompt = false
                    }
                }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            environment.analyticsService.hymnOpened(
                id: viewModel.hymn.id,
                category: viewModel.hymn.category.rawValue,
                source: source
            )
            
            if let hotd = environment.hymnService.hymnOfTheDay(),
               viewModel.hymn.id == hotd.id {
                environment.hymnOfTheDayEngagementService.markOpened(hymnID: viewModel.hymn.id)
            }
            
            viewStart = Date()
        }
        .onDisappear {
            if settings.stopPlaybackOnExit {
                environment.audioPlaybackService.stop()
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
}

