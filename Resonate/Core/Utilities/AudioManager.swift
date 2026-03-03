import AVFoundation
import SwiftUI
import Combine

final class AudioManager: NSObject, ObservableObject {
    
    static let shared = AudioManager()
    
    @Published var currentHymn: HymnIndex?
    @Published var isPlaying: Bool = false
    
    private var player: AVAudioPlayer?
    
    func play(hymn: HymnIndex) {
        
        // Stop current playback
        player?.stop()
        
        let fileName = String(format: "%03d", hymn.id)
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            
            currentHymn = hymn
            isPlaying = true
            
        } catch {
            print("Playback failed: \(error)")
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
        player?.stop()
        player = nil
        currentHymn = nil
        isPlaying = false
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
    }
}
