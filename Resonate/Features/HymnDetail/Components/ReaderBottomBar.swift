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
                    .font(.system(size: 18, weight: .medium))
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
                        .font(.system(size: 28, weight: .semibold))
                        .frame(width: 58, height: 58)
                        .background(controlBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

            case .downloading:
                ProgressView()

            case .remoteOnly, .unavailable, .failed(_):
                Image(systemName: "speaker.slash")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
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
            colorScheme == .dark ? Color.black.opacity(0.22) : Color.white.opacity(0.90)
        )
    }

    private var controlBackground: some ShapeStyle {
        colorScheme == .dark ? AnyShapeStyle(Color.white.opacity(0.08)) : AnyShapeStyle(Color(.secondarySystemBackground))
    }
}
