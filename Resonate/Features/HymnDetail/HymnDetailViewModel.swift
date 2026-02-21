import Foundation
import SwiftUI
import Combine

final class HymnDetailViewModel: ObservableObject {
    
    @Published var hymn: HymnIndex
    @Published private(set) var detail: HymnDetail?
    @Published var selectedLanguage: Language
    
    private let hymnService: HymnService
    
    init(index: HymnIndex, hymnService: HymnService) {
        self.hymn = index
        self.selectedLanguage = index.language
        self.hymnService = hymnService
        loadDetail()
    }
    
    private func loadDetail() {
        detail = hymnService.detail(for: hymn.id)
    }
    
    var availableLanguages: [Language] {
        [.english, .french, .twi] // later: derive from data
    }
    
    var versesForSelectedLanguage: [[String]] {
        detail?.verses ?? []
    }
    
    var hasNext: Bool {
        hymnService.hymn(after: hymn.id) != nil
    }
    
    var hasPrevious: Bool {
        hymnService.hymn(before: hymn.id) != nil
    }
    
    func nextHymn() {
        guard let next = hymnService.hymn(after: hymn.id) else { return }
        hymn = next
        loadDetail()
    }
    
    func previousHymn() {
        guard let previous = hymnService.hymn(before: hymn.id) else { return }
        hymn = previous
        loadDetail()
    }
    
}
