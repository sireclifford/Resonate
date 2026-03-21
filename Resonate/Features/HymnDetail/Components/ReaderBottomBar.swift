import SwiftUI

struct ReaderBottomBar: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var audioPlaybackService: AccompanimentPlaybackService
    
    let hymnID: Int
    let hasNext: Bool
    let hasPrevious: Bool
    let onPrevious: () -> Void
    let onPlayToggle: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(PremiumTheme.scaledSystem(size: 18, weight: .medium))
                    .frame(width: 40, height: 40)
                    .background(controlBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(!hasPrevious)

            Spacer()

            let state = audioPlaybackService.fileState(for: hymnID)

            switch state {

            case .downloaded:
                Button(action: onPlayToggle) {
                    Image(systemName: audioPlaybackService.isPlaying ? "pause.fill" : "play.fill")
                        .font(PremiumTheme.scaledSystem(size: 28, weight: .semibold))
                        .frame(width: 58, height: 58)
                        .background(controlBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

            case .downloading:
                ProgressView()

            case .remoteOnly, .unavailable, .failed(_):
                Image(systemName: "speaker.slash")
                    .font(PremiumTheme.scaledSystem(size: 22, weight: .medium))
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
            }

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(PremiumTheme.scaledSystem(size: 18, weight: .medium))
                    .frame(width: 40, height: 40)
                    .background(controlBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(!hasNext)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .background(
            PremiumTheme.panelFill(for: colorScheme).opacity(colorScheme == .dark ? 0.88 : 0.94)
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(PremiumTheme.border(for: colorScheme))
                .frame(height: 1)
        }
    }

    private var controlBackground: some ShapeStyle {
        AnyShapeStyle(PremiumTheme.subtleFill(for: colorScheme))
    }
}
