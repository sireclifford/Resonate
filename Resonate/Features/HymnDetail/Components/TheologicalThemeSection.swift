import SwiftUI

struct TheologicalThemeSection: View {
    
    let theme: String
    
    var body: some View {
        StorySectionContainer(title: "Theological Theme") {
            StoryBodyText(text: theme)
        }
    }
}
