import SwiftUI

struct HymnDetailView: View {

    let hymn: Hymn

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text(hymn.title)
                    .font(.title)
                    .bold()

                ForEach(hymn.verses.indices, id: \.self) { verseIndex in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verse \(verseIndex + 1)")
                            .font(.headline)

                        ForEach(hymn.verses[verseIndex], id: \.self) { line in
                            Text(line)
                        }
                    }
                }

                if let chorus = hymn.chorus {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chorus")
                            .font(.headline)

                        ForEach(chorus, id: \.self) { line in
                            Text(line)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("\(hymn.id)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
