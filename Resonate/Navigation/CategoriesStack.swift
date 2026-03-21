import SwiftUI

struct CategoriesStack: View {
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
                CategoriesView(environment: environment)
                    .navigationDestination(for: HymnCategory.self) { category in
                        CategoryDetailView(
                            category: category,
                            hymns: environment.categoryViewModel.hymns(for: category),
                            environment: environment,
                            favouritesService: environment.favouritesService
                        )
                    }
                    .navigationDestination(for: HymnIndex.self) { index in
                        HymnDetailView(
                            index: index,
                            environment: environment,
                            source: "category"
                        )
                    }
            }
        }
    }
}
