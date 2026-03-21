import SwiftUI

struct HymnCardView: View {
    let index: HymnIndex
    let isFavourite: Bool
    let onFavouriteToggle: () -> Void
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAudioBadge = false

    var body: some View {
        let audioState = environment.accompanimentPlaybackService.fileState(for: index.id)
        ZStack {
            HymnCardBackground(seed: index.id)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    audioBadgeView(for: audioState)

                    Spacer(minLength: 10)

                    favouriteButton
                }
                .frame(height: 38, alignment: .top)

                Spacer(minLength: 12)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text("Hymn \(index.id)")
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(PremiumTheme.accent(for: colorScheme))

                        Text("•")
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme).opacity(0.5))

                        Text("\(index.verseCount) verses")
                            .font(PremiumTheme.metadataFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    }

                    Text(index.title)
                        .font(PremiumTheme.cardTitleFont())
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(index.category.title)
                        .font(PremiumTheme.metadataFont())
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                        .lineLimit(1)
                }
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 244, alignment: .top)
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

    @ViewBuilder
    private func audioBadgeView(for state: AccompanimentPlaybackService.FileState) -> some View {
        if let audioBadge = audioBadge(for: state) {
            HStack(spacing: 6) {
                Image(systemName: audioBadge.systemImage)
                    .font(PremiumTheme.badgeFont())

                Text(audioBadge.title)
                    .font(PremiumTheme.badgeFont())
            }
            .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(PremiumTheme.searchFieldFill(for: colorScheme))
            )
            .overlay(
                Capsule()
                    .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
            )
            .clipShape(Capsule())
            .scaleEffect(showAudioBadge ? 1 : 0.85)
            .opacity(showAudioBadge ? 1 : 0)
            .animation(.easeOut(duration: 0.3), value: showAudioBadge)
            .onAppear {
                showAudioBadge = true
            }
        } else {
            Color.clear
                .frame(width: 92, height: 30)
        }
    }

    private var favouriteButton: some View {
        Button(action: onFavouriteToggle) {
            Image(systemName: isFavourite ? "heart.fill" : "heart")
                .foregroundStyle(isFavourite ? .red : PremiumTheme.primaryText(for: colorScheme))
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(PremiumTheme.searchFieldFill(for: colorScheme))
                )
                .overlay(
                    Circle()
                        .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
