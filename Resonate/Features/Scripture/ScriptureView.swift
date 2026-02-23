import SwiftUI
import YouVersionPlatform

struct ScriptureView: View {
    
    let reference: ScriptureReference
    let bibleID: Int
    
    var body: some View {
        BibleTextView(
            BibleReference(
                versionId: bibleID,
                bookUSFM: reference.bookUSFM,
                chapter: reference.chapter,
                verse: reference.verseStart
            )
        )
    }
}
