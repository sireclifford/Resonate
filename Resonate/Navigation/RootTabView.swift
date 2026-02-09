import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(environment: environment)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                FavouritesView(environment: environment)
            }
            .tabItem {
                Label("Favourites", systemImage: "heart")
            }
            NavigationStack {
                CategoriesView(environment: environment)
            }
            .tabItem {
                Label("Categories", systemImage: "square.grid.2x2")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

