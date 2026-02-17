import AVFoundation
import Combine

final class AudioPlaybackService: NSObject, ObservableObject {
    
    @Published private(set) var isPlaying: Bool = false
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
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()

            isPlaying = true

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
           isPlaying = false
    }
}

extension AudioPlaybackService: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}
