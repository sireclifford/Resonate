import SwiftUI

struct FavouritesStack: View {
    let environment: AppEnvironment
    @State private var path = NavigationPath()
    @ObservedObject private var audioService: AccompanimentPlaybackService

    init(environment: AppEnvironment) {
        self.environment = environment
        _audioService = ObservedObject(wrappedValue: environment.accompanimentPlaybackService)
    }

    var body: some View {
        ZStack {
            PremiumScreenBackground()

            NavigationStack(path: $path) {
                FavouritesView(environment: environment)
                    .navigationDestination(for: HymnIndex.self) { index in
                        HymnDetailView(
                            index: index,
                            environment: environment,
                            source: "favourites"
                        )
                    }
            }
        }
    }
}
