import SwiftUI

struct HymnStoryView: View {
    
    let story: HymnStory
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            PremiumScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    StoryHeaderView(story: story)
                    
                    if let historicalContext = story.historicalContext, !historicalContext.isEmpty {
                        HistoricalContextSection(
                            text: historicalContext
                        )
                    }
                    
                    if let theme = story.theologicalTheme, !theme.isEmpty {
                        TheologicalThemeSection(theme: theme)
                    }
                    
                    if let references = story.scriptureReferences, !references.isEmpty {
                        ScriptureSection(
                            references: references,
                            versionId: environment.settingsService.selectedBibleID
                        )
                    }
                    
                    if let music = story.music {
                        MusicalDetailsSection(
                            music: music
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("Story")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(PremiumTheme.tabBarFill(for: colorScheme), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
