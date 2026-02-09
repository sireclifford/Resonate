import SwiftUI

struct ReaderBottomBar: View {

    let canPlay: Bool
    let isPlaying: Bool
    let onPrevious: () -> Void
    let onPlayToggle: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {

            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
            }

            Spacer()

            if canPlay {
                Button(action: onPlayToggle) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22, weight: .medium))
                }
            }

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
}
