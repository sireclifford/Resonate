import Foundation
import SwiftUI
import Combine

final class HymnDetailViewModel: ObservableObject {
    
    let hymn: Hymn
    @Published var selectedLanguage: Language
    @Published var fontSize: ReaderFontSize = .medium
    @Published var isPlaying: Bool = false
    
    init(hymn: Hymn) {
        self.hymn = hymn
        self.selectedLanguage = hymn.language
    }
    
    var availableLanguages: [Language] {
        [.english, .french, .twi] // later: derive from data
    }
    
    var versesForSelectedLanguage: [[String]] {
        // for now hymn.language == selectedLanguage
        // later: fetch translated verses
        hymn.verses
    }
    
    func play(
            playbackService: MidiPlaybackService,
            tuneService: TuneService
        ) {
            playbackService.play(hymn: hymn, tuneService: tuneService)
            isPlaying = true
        }
    
    func stop(playbackService: MidiPlaybackService) {
            playbackService.stop()
            isPlaying = false
        }
    
}
