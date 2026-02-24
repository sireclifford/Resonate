import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @ObservedObject private var settings: AppSettingsService
    @ObservedObject private var audioService: AudioPlaybackService
    
    @State private var selectedTab = 0
    
    init(environment: AppEnvironment) {
        _settings = ObservedObject(
            wrappedValue: environment.settingsService
        )
        
        _audioService = ObservedObject(
               wrappedValue: environment.audioPlaybackService
           )
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeStack(environment: environment, selectedTab: $selectedTab)
                    .tag(0)
                    .tabItem { Label("Home", systemImage: "house") }
                
                FavouritesStack(environment: environment)
                    .tag(1)
                    .tabItem { Label("Favourites", systemImage: "heart") }
                
                CategoriesStack(environment: environment)
                    .tag(2)
                    .tabItem { Label("Categories", systemImage: "square.grid.2x2") }
                
                SettingsStack(environment: environment)
                    .tag(3)
                    .tabItem { Label("Settings", systemImage: "gear") }
            }
                .preferredColorScheme(settings.theme.colorScheme)
                .padding(.top, audioService.currentHymnID != nil ? 72 : 0)
                .overlay(alignment: .top) {
                    if audioService.currentHymnID != nil {
                        MiniPlayerView(environment: environment)
                            .environmentObject(environment)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                }
        }
    }
    
}
