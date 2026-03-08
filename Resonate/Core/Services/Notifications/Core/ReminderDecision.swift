import Foundation

enum SuppressionReason: Equatable, Codable {
    case disabled
    case permissionDenied
    case alreadyEngagedToday
    case noContentAvailable
    case outsideCampaignWindow
    case unchanged
}

enum ReminderDecision: Equatable {
    case schedule(snapshot: ReminderSnapshot, payload: ReminderPayload)
    case cancel(identifier: ReminderIdentifier)
    case suppress(reason: SuppressionReason)
    case none
}
