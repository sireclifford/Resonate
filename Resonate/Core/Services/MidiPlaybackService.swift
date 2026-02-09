import Foundation
import AVFoundation

final class MidiPlaybackService {
    private var player: AVMIDIPlayer?
    
    func play(hymn: Hymn, tuneService: TuneService){
        stop()
        
        guard let midiURL = tuneService.tuneURL(for: hymn) else { print("❌ MIDI file not found for hymn \(hymn.id)")
            return }
        do {
            player = try AVMIDIPlayer(contentsOf: midiURL, soundBankURL: nil)
            player?.prepareToPlay()
            player?.play {
                print("✅ Finished playing hymn \(hymn.id)")
            }
        } catch {
            print("❌ Failed to play MIDI: \(error)")
        }
    }
    
    func stop() {
        player?.stop()
        player = nil
    }
    
    var isPlaying: Bool {
        player?.isPlaying ?? false
    }
}
