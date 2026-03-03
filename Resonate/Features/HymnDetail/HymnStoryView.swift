import SwiftUI

struct HymnStoryView: View {
    
    let story: HymnStory
    @EnvironmentObject var environment: AppEnvironment
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                
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
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
