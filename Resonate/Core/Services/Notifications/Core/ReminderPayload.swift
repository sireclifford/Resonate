import Foundation

struct ReminderPayload: Equatable, Codable {
    let identifier: ReminderIdentifier
    let type: ReminderType
    let title: String
    let subtitle: String?
    let body: String
    let soundEnabled: Bool
    let badge: Int?
    let userInfo: [String: String]
}
