import SwiftUI

struct HymnCardView: View {

    let hymn: Hymn
    let isFavourite: Bool
    let onFavouriteToggle: () -> Void
    @EnvironmentObject var environment: AppEnvironment
    @State private var showAudioBadge = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                HymnCardBackground(seed: hymn.id)
                    .aspectRatio(1, contentMode: .fit)

                // 🔊 Audio Badge (Top-Left)
                if environment.tuneService.tuneExists(for: hymn) {
                    VStack {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.caption)
                                .padding(6)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .scaleEffect(showAudioBadge ? 1 : 0.6)
                                .opacity(showAudioBadge ? 1 : 0)
                                .animation(.easeOut(duration: 0.3), value: showAudioBadge)

                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(8)
                    .onAppear {
                        showAudioBadge = true
                    }
                }

                // ❤️ Favourite (Top-Right)
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onFavouriteToggle) {
                            Image(systemName: isFavourite ? "heart.fill" : "heart")
                                .foregroundColor(isFavourite ? .red : .white)
                                .padding(8)
                        }
                    }
                    Spacer()
                }
                .padding(8)
            }

            Text("Hymns \(hymn.id) • \(hymn.verses.count) Verses")
                .font(.josefin(size: 13))

            Text(hymn.title)
                .font(.josefin(size: 15, weight: .medium))
                .lineLimit(2)

            Text(hymn.category.title)
                .font(.josefin(size: 11))
        }
    }
}
