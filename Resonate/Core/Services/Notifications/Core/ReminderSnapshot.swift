import Foundation

struct ReminderSnapshot: Equatable, Codable {
    let identifier: ReminderIdentifier
    let type: ReminderType
    let nextFireDate: Date
    let schedule: ReminderSchedule
    let contentHash: String
}
