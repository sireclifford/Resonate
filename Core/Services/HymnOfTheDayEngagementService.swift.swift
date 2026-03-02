import Foundation

final class HymnOfTheDayEngagementService {
    private let persistence: PersistenceService
    private let calendar = Calendar.current
    
    private enum Keys {
        static let lastOpenedHymnID = "last_opened_hymn_id"
        static let lastOpenedHymnDate = "last_opened_hymn_date"
    }
    
    init(persistence: PersistenceService) {
        self.persistence = persistence
    }
    
    func markOpened(hymnID: Int) {
        persistence.save(hymnID, for: Keys.lastOpenedHymnID)
        persistence.save(Date(), for: Keys.lastOpenedHymnDate)
    }
    
    func hasOpenedToday(hymnID: Int) -> Bool {
        guard
            let storedID: Int = persistence.load(Int.self, for: Keys.lastOpenedHymnID),
            let storedDate: Date = persistence.load(Date.self, for: Keys.lastOpenedHymnDate)
        else { return false }

        return storedID == hymnID &&
               calendar.isDateInToday(storedDate)
    }
}
