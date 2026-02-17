import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        TabView {
            // ✅ Home owns its own NavigationStack
            HomeView(environment: environment)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            // ✅ Favourites owns its own NavigationStack
            FavouritesView(environment: environment)
                .tabItem {
                    Label("Favourites", systemImage: "heart")
                }

            // ✅ Categories owns its own NavigationStack
            CategoriesView(environment: environment)
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2")
                }

            // ✅ Settings (optional NavigationStack inside SettingsView if needed)
            SettingsView(environment: environment)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
