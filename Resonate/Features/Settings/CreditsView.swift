import SwiftUI

struct CreditsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("Credits")
                    .font(.title2)
                    .bold()
                
                Group {
                    Text("Hymn Data Source:")
                    Text("Placeholder - Source of hymn lyrics.")
                    
                    Text("Tune Source:")
                    Text("Placeholder - MIDI or audio arrangements.")
                    
                    Text("Acknowledgments:")
                    Text("Special thanks to contributors and testers.")
                }
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Credits")
    }
}

