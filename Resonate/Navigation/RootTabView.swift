import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var settings: AppSettingsService
    
    @State private var showOnboarding = false
    
    @State private var selectedTab = 0
    
    init(environment: AppEnvironment) {
        _settings = ObservedObject(
            wrappedValue: environment.settingsService
        )
    }
    
    var body: some View {
        ZStack {
            PremiumScreenBackground()

            TabView(selection: $selectedTab) {
                HomeStack(environment: environment, selectedTab: $selectedTab)
                    .tag(0)
                    .tabItem { Label("Home", systemImage: "house.fill") }
                
                FavouritesStack(environment: environment)
                    .tag(1)
                    .tabItem { Label("Library", systemImage: "books.vertical.fill") }
                
                CategoriesStack(environment: environment)
                    .tag(2)
                    .tabItem { Label("Categories", systemImage: "square.stack.fill") }
                
                SettingsStack(environment: environment)
                    .tag(3)
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            }
            .preferredColorScheme(settings.theme.colorScheme)
            .toolbarBackground(PremiumTheme.tabBarFill(for: settings.theme.colorScheme ?? colorScheme), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(settings.theme.colorScheme, for: .tabBar)
            .onChange(of: selectedTab) { oldValue, newValue in
                let tabName: String
                switch newValue {
                case 0: tabName = "home"
                case 1: tabName = "favourites"
                case 2: tabName = "categories"
                case 3: tabName = "settings"
                default: tabName = "unknown"
                }
                
                environment.analyticsService.log(
                    .tabSwitched,
                    parameters: [
                        .tab: tabName
                    ]
                )
            }
        }
    }
    
}
