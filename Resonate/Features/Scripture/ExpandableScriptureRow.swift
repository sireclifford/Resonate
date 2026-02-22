import SwiftUI
import YouVersionPlatform

struct ExpandableScriptureRow: View {
    
    let reference: ScriptureReference
    let versionId: Int
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Button {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(displayText)
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                BibleTextView(
                    BibleReference(
                        versionId: versionId,
                        bookUSFM: reference.bookUSFM,
                        chapter: reference.chapter,
                        verse: reference.verseStart
                    )
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private var displayText: String {
        if let end = reference.verseEnd {
            return "\(reference.bookUSFM) \(reference.chapter):\(reference.verseStart)-\(end)"
        } else {
            return "\(reference.bookUSFM) \(reference.chapter):\(reference.verseStart)"
        }
    }
    
    private var bookName: String {
        BibleBookNameMapper.displayName(for: reference.bookUSFM)
    }
}
