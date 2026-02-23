import SwiftUI

struct StoryHeaderView: View {
    
    let story: HymnStory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(story.title)
                .font(.custom("CormorantGaramond-SemiBold", size: 22))             .frame(maxWidth: .infinity, alignment: .center)
            
            Group {
                let authorText = [story.author, story.authorBirthDeath]
                    .compactMap { $0 }
                    .joined(separator: " ")

                if let year = story.yearWritten, !authorText.isEmpty {
                    Text("Written \(String(year)) • \(authorText)")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if !authorText.isEmpty {
                    Text(authorText)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .font(.custom("Avenir", size: 13))
            .foregroundColor(.secondary)
            
            Divider()
                .padding(.top, 8)
        }
    }
}
