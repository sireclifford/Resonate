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
                FavouritesView()
            }
            .tabItem {
                Label("Favourites", systemImage: "heart")
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

