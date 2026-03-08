import Foundation

enum ReminderType: String, Codable, CaseIterable, Hashable {
    case hymnOfTheDay
    case sabbath
    case event
    case seasonal
    case promotional
}
