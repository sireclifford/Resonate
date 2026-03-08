import Foundation
import UserNotifications

final class NotificationAuthorizationManager: NotificationAuthorizationManaging {
    func currentStatus() async -> NotificationAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return map(settings.authorizationStatus)
    }

    func requestAuthorization() async throws -> NotificationAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        let settings = await center.notificationSettings()
        return map(settings.authorizationStatus)
    }

    private func map(_ status: UNAuthorizationStatus) -> NotificationAuthorizationStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        case .provisional: return .provisional
        case .ephemeral: return .ephemeral
        @unknown default: return .denied
        }
    }
}
