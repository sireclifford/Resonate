import Foundation
import SwiftUI
import Combine

final class HymnDetailViewModel: ObservableObject {
    
    @Published var hymn: Hymn
    @Published var selectedLanguage: Language
    
    private let hymnService: HymnService
    
    init(hymn: Hymn, hymnService: HymnService) {
        self.hymn = hymn
        self.selectedLanguage = hymn.language
        self.hymnService = hymnService
    }
    
    var availableLanguages: [Language] {
        [.english, .french, .twi] // later: derive from data
    }
    
    var versesForSelectedLanguage: [[String]] {
        // for now hymn.language == selectedLanguage
        // later: fetch translated verses
        hymn.verses
    }
    
    var hasNext: Bool {
        hymnService.hymn(after: hymn) != nil
    }
    
    var hasPrevious: Bool {
        hymnService.hymn(before: hymn) != nil
    }
    
    func nextHymn() {
        guard let next = hymnService.hymn(after: hymn) else { return }
        hymn = next
    }
    
    func previousHymn() {
        guard let previous = hymnService.hymn(before: hymn) else { return }
        hymn = previous
    }
    
}
