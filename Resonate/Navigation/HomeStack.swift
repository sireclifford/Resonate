import SwiftUI

struct HomeStack: View {
    let environment: AppEnvironment
    @Binding var selectedTab: Int
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                environment: environment,
                onSelectHymn: { hymn in
                    path.append(hymn)
                },
                onSeeAll: {
                    selectedTab = 2
                }
            )
            .navigationDestination(for: Hymn.self) { hymn in
                HymnDetailView(
                    hymn: hymn,
                    environment: environment
                )
            }
            .navigationDestination(for: HymnCategory.self) { category in
                CategoryDetailView(
                    category: category,
                    hymns: environment.categoryViewModel.hymns(for: category),
                    environment: environment,
                    favouritesService: environment.favouritesService
                )
            }
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .allCategories:
                    CategoriesView(environment: environment)
                }
            }
        }
    }
}

enum HomeRoute: Hashable {
    case allCategories
}
