import SwiftUI

struct HymnDetailView: View {

    let environment: AppEnvironment
    @StateObject private var viewModel: HymnDetailViewModel

    init(hymn: Hymn, environment: AppEnvironment) {
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

                    Text(viewModel.hymn.title)
                        .font(.josefin(size: 26, weight: .semibold))

                    ForEach(viewModel.versesForSelectedLanguage.indices, id: \.self) { index in
                        VerseView(
                            title: "\(index + 1).",
                            lines: viewModel.versesForSelectedLanguage[index],
                            fontSize: viewModel.fontSize
                        )
                    }

                }
                .padding()
            }

            Divider()

            // Bottom bar
            ReaderBottomBar(
//                canPlay: environment.tuneService.tuneExists(for: viewModel.hymn),
                canPlay: true,
                isPlaying: viewModel.isPlaying,
                onPrevious: { /* next phase */ },
                onPlayToggle: {
                    if viewModel.isPlaying {
                        environment.midiPlaybackService.stop()
                        viewModel.isPlaying = false
                    } else {
                        environment.midiPlaybackService.play(
                            hymn: viewModel.hymn,
                            tuneService: environment.tuneService
                        )
                        viewModel.isPlaying = true
                    }
                },
                onNext: { /* next phase */ }
            )
        }
        .toolbar(.hidden, for: .tabBar)
        .onDisappear {
            environment.midiPlaybackService.stop()
            viewModel.isPlaying = false
        }
    }
}
