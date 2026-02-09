import AVFoundation

final class AudioPlaybackService {

    private var player: AVAudioPlayer?

    func play(hymn: Hymn, tuneService: TuneService) {
        stop()

        guard let url = tuneService.tuneURL(for: hymn) else {
            print("❌ Missing audio file")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            try session.setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()

            Haptics.light()
            print("▶️ Playing audio:", url.lastPathComponent)

        } catch {
            print("❌ Audio error:", error)
        }
    }

    func stop() {
        if player?.isPlaying == true {
            player?.stop()
            Haptics.light()
        }
        player = nil
    }

    var isPlaying: Bool {
        player?.isPlaying ?? false
    }
}
