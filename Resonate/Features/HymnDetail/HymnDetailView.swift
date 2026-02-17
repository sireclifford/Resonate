import SwiftUI

struct HymnDetailView: View {
    
    let environment: AppEnvironment
    let hymn: Hymn
    @StateObject private var viewModel: HymnDetailViewModel
    
    init(hymn: Hymn, environment: AppEnvironment) {
        self.hymn = hymn
        self.environment = environment
        _viewModel = StateObject(
            wrappedValue: HymnDetailViewModel(
                hymn: hymn,
                hymnService: environment.hymnService
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Top bar
            ReaderTopBar(
                hymn: viewModel.hymn,
                availableLanguages: viewModel.availableLanguages,
                selectedLanguage: viewModel.selectedLanguage,
                onLanguageSelect: { viewModel.selectedLanguage = $0 },
                fontSize: environment.settingsService.fontSize,
                onFontSelect: { environment.settingsService.fontSize = $0 },
                isFavourite: environment.favouritesService.isFavourite(viewModel.hymn),
                onFavouriteToggle: {
                    environment.favouritesService.toggle(viewModel.hymn)
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
                            fontSize: environment.settingsService.fontSize
                        )
                        
                        if let chorus = hymn.chorus {
                            ChorusView(lines: chorus)
                        }
                    }
                    
                }
                .padding()
            }
            
            // Bottom bar
            ReaderBottomBar(
                audioPlaybackService: environment.audioPlaybackService,
                canPlay: environment.tuneService.tuneExists(for: viewModel.hymn),
                hasNext: viewModel.hasNext,
                hasPrevious: viewModel.hasPrevious,
                onPrevious: { /* next phase */
                    environment.audioPlaybackService.stop()
                    viewModel.previousHymn()
                },
                onPlayToggle: {
                    environment.audioPlaybackService.togglePlayback(for: viewModel.hymn,
                                                                    tuneService: environment.tuneService
                    )
                },
                onNext: { /* next phase */
                    environment.audioPlaybackService.stop()
                    viewModel.nextHymn()
                }
            )
        }
        .navigationTitle(viewModel.hymn.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            environment.recentlyViewedService.record(hymn)
        }
        .onDisappear {
            environment.audioPlaybackService.stop()
        }
    }
}
