import Foundation
import UserNotifications

final class UserNotificationCenterClient: NotificationCenterClient {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func add(_ request: UNNotificationRequest) async throws {
        try await center.add(request)
    }

    func removePending(ids: [String]) async {
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    func removeDelivered(ids: [String]) async {
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }

    func pendingRequests() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }
}
