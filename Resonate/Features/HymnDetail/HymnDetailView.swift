import SwiftUI

struct HymnDetailView: View {
    
    let environment: AppEnvironment
    @ObservedObject private var settings: AppSettingsService
    @StateObject private var viewModel: HymnDetailViewModel
    @ObservedObject private var favouritesService: FavouritesService
    @State private var showStory = false
    
    let index: HymnIndex
    
    init(index: HymnIndex, environment: AppEnvironment) {
        self.index = index
        self.environment = environment
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
        .sheet(isPresented: $showStory) {
            NavigationStack {
                if let story = environment.hymnStoryService.story(for: viewModel.hymn.id) {
                    HymnStoryView(
                        story: story
                    )
                    .environmentObject(environment)
                } else {
                    StoryUnavailableView()
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            environment.recentlyViewedService.record(id: index.id)
            environment.analyticsService.hymnOpened(
                id: viewModel.hymn.id,
                category: viewModel.hymn.category.rawValue
            )
        }
        .onDisappear {
            if settings.stopPlaybackOnExit {
                environment.audioPlaybackService.stop()
            }
        }
    }
}
