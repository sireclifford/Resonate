import SwiftUI

struct HymnDetailView: View {
    
    let environment: AppEnvironment
    let hymn: Hymn
    @StateObject private var viewModel: HymnDetailViewModel
    
    init(hymn: Hymn, environment: AppEnvironment) {
        self.hymn = hymn
        self.environment = environment
        _viewModel = StateObject(
            wrappedValue: HymnDetailViewModel(hymn: hymn)
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
                fontSize: viewModel.fontSize,
                onFontSelect: { viewModel.fontSize = $0 },
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
                            fontSize: viewModel.fontSize
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
                isPlaying: viewModel.isPlaying,
                onPrevious: { /* next phase */
                    Haptics.light()
                },
                onPlayToggle: {
                    environment.audioPlaybackService.play(
                        hymn: hymn,
                        tuneService: environment.tuneService
                    )
                },
                onNext: { /* next phase */
                    Haptics.light()
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
            viewModel.isPlaying = false
            viewModel.stop(playbackService: environment.audioPlaybackService)
        }
    }
}
