import SwiftUI

struct HymnCardView: View {

    let index: HymnIndex
    let isFavourite: Bool
    let onFavouriteToggle: () -> Void
    @EnvironmentObject var environment: AppEnvironment
    @State private var showAudioBadge = false

    var body: some View {
        let audioState = environment.accompanimentPlaybackService.fileState(for: index.id)
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                HymnCardBackground(seed: index.id)
                    .frame(height: 180)

                if let audioBadge = audioBadge(for: audioState) {
                    VStack {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: audioBadge.systemImage)
                                    .font(.caption.weight(.semibold))

                                Text(audioBadge.title)
                                    .font(.caption2.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .scaleEffect(showAudioBadge ? 1 : 0.85)
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

            Text("Hymn \(index.id) • \(index.verseCount) Verses")
                .font(.josefin(size: 13))
                .frame(height: 18, alignment: .topLeading)

            Text(index.title)
                .font(.josefin(size: 15, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: 22, alignment: .topLeading)

            Text(index.category.title)
                .font(.josefin(size: 11))
                .lineLimit(1)
                .frame(height: 14, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260, alignment: .top)
    }

    private struct AudioBadge {
        let title: String
        let systemImage: String
    }

    private func audioBadge(for state: AccompanimentPlaybackService.FileState) -> AudioBadge? {
        switch state {
        case .downloaded:
            return AudioBadge(title: "Downloaded", systemImage: "music.note")
        case .remoteOnly:
            return AudioBadge(title: "Online", systemImage: "icloud.and.arrow.down")
        case .downloading:
            return AudioBadge(title: "Downloading", systemImage: "arrow.down.circle")
        case .unavailable:
            return nil
        case .failed:
            return nil
        }
    }
}
