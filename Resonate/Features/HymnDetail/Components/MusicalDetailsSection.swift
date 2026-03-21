import SwiftUI

struct MusicalDetailsSection: View {
    
    let music: HymnMusic
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        StorySectionContainer(title: "Musical Structure") {
            VStack(alignment: .leading, spacing: 10) {
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
        HStack(alignment: .top, spacing: 14) {
            Text(title)
                .font(PremiumTheme.captionFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(PremiumTheme.scaledSystem(size: 15, weight: .medium))
                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
