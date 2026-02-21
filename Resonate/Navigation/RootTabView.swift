import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @ObservedObject private var settings: AppSettingsService
    
    @State private var selectedTab = 0

    init(environment: AppEnvironment) {
        _settings = ObservedObject(
            wrappedValue: environment.settingsService
        )
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // ✅ Home owns its own NavigationStack
            HomeStack(environment: environment, selectedTab: $selectedTab)
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            // ✅ Favourites owns its own NavigationStack
            FavouritesStack(environment: environment)
                .tag(1)
                .tabItem {
                    Label("Favourites", systemImage: "heart")
                }

            // ✅ Categories owns its own NavigationStack
            CategoriesStack(environment: environment)
                .tag(2)
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2")
                }

            // ✅ Settings (optional NavigationStack inside SettingsView if needed)
            SettingsStack(environment: environment)
                .tag(3)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .preferredColorScheme(settings.theme.colorScheme)
    }
}
