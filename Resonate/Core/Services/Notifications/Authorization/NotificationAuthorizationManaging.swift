import Foundation

protocol NotificationAuthorizationManaging {
    func currentStatus() async -> NotificationAuthorizationStatus
    func requestAuthorization() async throws -> NotificationAuthorizationStatus
}
