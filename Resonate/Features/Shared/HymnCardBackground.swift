import SwiftUI

struct HymnCardBackground: View {

    let seed: Int

    var body: some View {
        LinearGradient(
            colors: palette,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.15)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var palette: [Color] {
        let palettes: [[Color]] = [
            [.blue.opacity(0.6), .purple.opacity(0.6)],
            [.indigo.opacity(0.6), .teal.opacity(0.6)],
            [.green.opacity(0.6), .mint.opacity(0.6)],
            [.orange.opacity(0.6), .pink.opacity(0.6)],
            [.brown.opacity(0.5), .yellow.opacity(0.5)]
        ]
        return palettes[seed % palettes.count]
    }
}
