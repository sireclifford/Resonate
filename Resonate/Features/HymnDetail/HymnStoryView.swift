import SwiftUI
import YouVersionPlatform

struct HymnStoryView: View {
    
    let story: HymnStory
    let hymnTitle: String
    let hymnNumber: Int
    @EnvironmentObject private var environment: AppEnvironment
    @State private var expandedReferenceID: String?
    
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
                
                if let scriptures = story.scriptureReferences {
                    StoryCard {
                        SectionHeader(title: "Scripture References", systemImage: "book")
                        
                        VStack(spacing: 16) {
                            ForEach(scriptures) { reference in
                                scriptureRow(for: reference)
                            }
                        }
                    }
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("Hymn Story")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func scriptureRow(for reference: ScriptureReference) -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Button {
                withAnimation(.easeInOut) {
                    if expandedReferenceID == reference.id {
                        expandedReferenceID = nil
                    } else {
                        expandedReferenceID = reference.id
                    }
                }
            } label: {
                HStack {
                    Text(displayText(for: reference))
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: expandedReferenceID == reference.id ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            
            if expandedReferenceID == reference.id {
                BibleTextView(
                    BibleReference(
                        versionId: environment.settingsService.selectedVersionId,
                        bookUSFM: reference.bookUSFM,
                        chapter: reference.chapter,
                        verse: reference.verseStart
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.black.opacity(0.05))
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private func displayText(for reference: ScriptureReference) -> String {
        
        let book = BibleBookNameMapper.displayName(for: reference.bookUSFM)
        
        if let end = reference.verseEnd {
            return "\(book) \(reference.chapter):\(reference.verseStart)-\(end)"
        } else {
            return "\(book) \(reference.chapter):\(reference.verseStart)"
        }
    }
}
