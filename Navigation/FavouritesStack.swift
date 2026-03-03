import SwiftUI

struct FavouritesStack: View {
    let environment: AppEnvironment
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            FavouritesView(environment: environment)
                .navigationDestination(for: HymnIndex.self) { index in
                    HymnDetailView(
                        index: index,
                        environment: environment
                    )
                }
        }
    }
}
