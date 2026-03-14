import Foundation

enum ReminderSchedule: Equatable, Codable {
    case daily(hour: Int, minute: Int)
    case weekly(weekday: Int, hour: Int, minute: Int)
    case oneShot(Date)
}

extension ReminderSchedule {
    static func oneTime(on date: Date, calendar: Calendar = .current) -> ReminderSchedule {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        guard let normalizedDate = calendar.date(from: components) else {
            return .oneShot(date)
        }
        return .oneShot(normalizedDate)
    }
}
