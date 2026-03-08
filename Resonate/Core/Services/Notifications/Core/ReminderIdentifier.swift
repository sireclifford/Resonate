import Foundation

struct ReminderIdentifier: Hashable, Codable {
    let rawValue: String

    static let hotdPrimary = ReminderIdentifier(rawValue: "reminder.hymn_of_the_day.primary")

    static func sabbathPrimary() -> ReminderIdentifier {
        ReminderIdentifier(rawValue: "reminder.sabbath.primary")
    }

    static func event(_ eventID: String) -> ReminderIdentifier {
        ReminderIdentifier(rawValue: "reminder.event.\(eventID)")
    }

    static func campaign(_ name: String) -> ReminderIdentifier {
        ReminderIdentifier(rawValue: "reminder.campaign.\(name)")
    }
}
