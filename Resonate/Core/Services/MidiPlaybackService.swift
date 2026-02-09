import Foundation
import AVFoundation

final class MidiPlaybackService {

    private var player: AVMIDIPlayer?

    func play(hymn: Hymn, tuneService: TuneService) {
        stop()

        guard let url = tuneService.tuneURL(for: hymn) else {
            return
        }

        do {
            player = try AVMIDIPlayer(contentsOf: url, soundBankURL: nil)
            player?.prepareToPlay()
            player?.play()

            Haptics.light()

        } catch {
            print("Failed to play MIDI:", error)
        }
    }

    func stop() {
        if player != nil {
            player?.stop()
            player = nil
            Haptics.light()
        }
    }

    var isPlaying: Bool {
        player?.isPlaying ?? false
    }
}
