import Foundation

enum ReminderSchedule: Equatable, Codable {
    case daily(hour: Int, minute: Int)
    case weekly(weekday: Int, hour: Int, minute: Int)
    case oneShot(Date)
}
