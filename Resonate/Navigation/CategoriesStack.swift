import SwiftUI

struct CategoriesStack: View {
    let environment: AppEnvironment
    @State private var path = NavigationPath()

    var body: some View {
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
                .navigationDestination(for: Hymn.self) { hymn in
                    HymnDetailView(
                        hymn: hymn,
                        environment: environment
                    )
                }
        }
    }
}
