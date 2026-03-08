import Foundation

struct ReminderContext {
    let now: Date

    // HOTD
    let hotdEnabled: Bool
    let hotdTime: Date
    let hotdHymnID: Int?
    let hotdTitle: String?
    let hotdOpenedToday: Bool

    // Future
    let sabbathEnabled: Bool
    let sabbathTime: Date?

    // Authorization
    let authorizationGranted: Bool
}
