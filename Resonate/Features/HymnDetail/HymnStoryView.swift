import SwiftUI

struct HymnStoryView: View {
    
    let story: HymnStory
    let hymnTitle: String
    let hymnNumber: Int
    
    var body: some View {
        
        VStack(spacing: 6) {
            Text("Hymn \(hymnNumber)")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(hymnTitle)
                .font(.title3)
                .fontWeight(.semibold)

            if let tune = story.music?.tuneName,
               let key = story.music?.originalKey {
                Text("\(tune) • \(key)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
        
        ScrollView {
            VStack(spacing: 28) {
                
                if let context = story.historicalContext {
                    StoryCard {
                        SectionHeader(title: "Historical Context", systemImage: "clock")
                        Text(context)
                            .font(.body)
                            .lineSpacing(4)
                    }
                }
                
                if let theme = story.theologicalTheme {
                    StoryCard {
                        SectionHeader(title: "Theological Theme", systemImage: "cross")
                        Text(theme)
                            .font(.body)
                            .lineSpacing(4)
                    }
                }
                
                if let music = story.music {
                    StoryCard {
                        SectionHeader(title: "Musical Information", systemImage: "music.note")
                        
                        VStack(spacing: 14) {
                            
                            if let key = music.originalKey {
                                InfoRow(title: "Original Key", value: key)
                            }
                            
                            if let time = music.timeSignature {
                                InfoRow(title: "Time Signature", value: time)
                            }
                            
                            if let tempo = music.tempoMarking {
                                InfoRow(title: "Tempo", value: tempo)
                            }
                            
                            if let bpm = music.bpm {
                                InfoRow(title: "BPM", value: "\(bpm)")
                            }
                            
                            if let style = music.performanceStyle {
                                InfoRow(title: "Style", value: style)
                            }
                            
                            if let difficulty = music.congregationalDifficulty {
                                HStack {
                                    Text("Difficulty")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    DifficultyDots(level: difficulty)
                                }
                                Divider().opacity(0.3)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("Hymn Story")
        .navigationBarTitleDisplayMode(.inline)
    }
}
