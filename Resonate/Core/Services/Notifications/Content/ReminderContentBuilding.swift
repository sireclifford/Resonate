import Foundation

protocol ReminderContentBuilding {
    func payload(for context: ReminderContext) -> ReminderPayload?
}
