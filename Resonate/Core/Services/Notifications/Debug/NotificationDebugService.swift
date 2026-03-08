import Foundation
import Combine
import UserNotifications

@MainActor
final class NotificationDebugService: ObservableObject {
    @Published private(set) var pendingIdentifiers: [String] = []
    @Published private(set) var authorizationStatus: NotificationAuthorizationStatus = .notDetermined

    private let client: NotificationCenterClient
    private let authorizationManager: NotificationAuthorizationManaging

    init(
        client: NotificationCenterClient,
        authorizationManager: NotificationAuthorizationManaging
    ) {
        self.client = client
        self.authorizationManager = authorizationManager
    }

    func refresh() async {
        authorizationStatus = await authorizationManager.currentStatus()
        let pending = await client.pendingRequests()
        pendingIdentifiers = pending.map(\.identifier).sorted()
    }
}
