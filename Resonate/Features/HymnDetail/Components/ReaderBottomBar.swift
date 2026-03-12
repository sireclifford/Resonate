import SwiftUI

struct ReaderBottomBar: View {
    
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
            }.disabled(!hasPrevious)

            Spacer()

            let state = audioPlaybackService.fileState(for: hymnID)

            switch state {

            case .downloaded:
                Button(action: onPlayToggle) {
                    Image(systemName: audioPlaybackService.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .semibold))
                }

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
            }.disabled(!hasNext)
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))

    }
}
