import Foundation

protocol ReminderContentBuilding {
    func payload(for context: ReminderContext, scheduledFor fireDate: Date?) -> ReminderPayload?
}
