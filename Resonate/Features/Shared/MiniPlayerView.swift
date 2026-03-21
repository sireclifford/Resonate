import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var audio: AccompanimentPlaybackService

    init(environment: AppEnvironment) {
        _audio = ObservedObject(wrappedValue: environment.accompanimentPlaybackService)
    }

    var body: some View {
        if let id = audio.currentHymnID,
           let hymn = environment.hymnService.index.first(where: { $0.id == id }) {
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Text("\(hymn.id)")
                        .font(PremiumTheme.scaledSystem(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(PremiumTheme.searchFieldFill(for: colorScheme))
                        )
                        .overlay(
                            Capsule()
                                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(hymn.title)
                            .font(PremiumTheme.scaledSystem(size: 16, weight: .semibold, design: .serif))
                            .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                            .lineLimit(1)

                        Text(hymn.category.title)
                            .font(PremiumTheme.metadataFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    Button {
                        Haptics.light()
                        audio.togglePlayback(for: id)
                        if let id = environment.accompanimentPlaybackService.currentHymnID {
                            environment.analyticsService.miniPlayerToggled(id: id)
                        }
                    } label: {
                        Group {
                            if audio.isLoading {
                                ProgressView()
                                    .scaleEffect(0.72)
                            } else {
                                Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
                                    .font(PremiumTheme.scaledIconFont(size: 17, weight: .bold, relativeTo: .headline))
                            }
                        }
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                        .frame(width: 38, height: 38)
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

                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                            audio.stop()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(PremiumTheme.scaledIconFont(size: 13, weight: .semibold, relativeTo: .caption1))
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                }

                ProgressView(value: audio.progress)
                    .progressViewStyle(.linear)
                    .tint(PremiumTheme.accent(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .scaleEffect(x: 1, y: 0.55, anchor: .center)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(PremiumTheme.tabBarFill(for: colorScheme).opacity(colorScheme == .dark ? 0.92 : 0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
            )
            .shadow(color: PremiumTheme.shadow(for: colorScheme).opacity(0.32), radius: 20, y: 10)
            .padding(.horizontal, 16)
            .padding(.bottom, 6)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onTapGesture {
                guard environment.activeHymnDetailID != id else { return }
                environment.analyticsService.miniPlayerTapped(id: id)
                environment.navigationService.openHymn(
                    id: id,
                    source: "miniplayer"
                )
            }
        }
    }
}
