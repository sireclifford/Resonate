import AVFoundation
import Combine

final class AudioPlaybackService: NSObject, ObservableObject {
    
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentHymnID: Int?
    private var player: AVAudioPlayer?
    
    func togglePlayback(for hymn: Hymn, tuneService: TuneService) {
        
        // Same hymn already loaded
        if currentHymnID == hymn.id {
            
            if isPlaying {
                player?.pause()
                isPlaying = false
            } else {
                player?.play()
                isPlaying = true
            }
            
            return
        }
        
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
            
            currentHymnID = hymn.id
            isPlaying = true
            
            Haptics.light()
            print("▶️ Playing audio:", url.lastPathComponent)
            
        } catch {
            print("❌ Audio error:", error)
        }
    }
    
    func stop() {
        player?.stop()
        player = nil
        currentHymnID = nil
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
