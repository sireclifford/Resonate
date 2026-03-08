import Foundation
import UserNotifications

protocol NotificationCenterClient {
    func add(_ request: UNNotificationRequest) async throws
    func removePending(ids: [String]) async
    func removeDelivered(ids: [String]) async
    func pendingRequests() async -> [UNNotificationRequest]
}
