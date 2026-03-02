import SwiftUI

struct MusicalDetailsSection: View {
    
    let music: HymnMusic
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Musical Structure")
                .font(.custom("CormorantGaramond-SemiBold", size: 20))
            
            VStack(alignment: .leading, spacing: 8) {
                
                if let tune = music.tuneName { infoRow("Tune", tune) }
                infoRow("Composer", music.composer ?? "Unknown")
                if let year = music.yearComposed { infoRow("Year", "\(year)") }
                if let key = music.originalKey { infoRow("Key", key) }
                if let time = music.timeSignature { infoRow("Time Signature", time) }
                if let tempo = music.tempoMarking, let bpm = music.bpm {
                    infoRow("Tempo", "\(tempo) • \(bpm) BPM")
                } else if let tempo = music.tempoMarking {
                    infoRow("Tempo", tempo)
                } else if let bpm = music.bpm {
                    infoRow("Tempo", "\(bpm) BPM")
                }
                
                if let instruments = music.suggestedInstrumentation, !instruments.isEmpty {
                    infoRow(
                        "Instrumentation",
                        instruments.joined(separator: ", ")
                    )
                }
            }
        }
    }
    
    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.custom("Avenir", size: 14))
                .foregroundColor(.secondary)
                .frame(width: 130, alignment: .leading)
            
            Text(value)
                .font(.custom("Avenir", size: 14))
        }
    }
}
