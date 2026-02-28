import Testing

@testable import HymnAppModule // adjust as needed to access NotificationService and HymnService

final class NotificationServiceTests: TestCase {
  @Test("testNotificationServiceCallback", "onNotificationTapped closure is called with the correct hymnID") func testNotificationServiceCallback() {
    let notificationService = FakeNotificationService()
    let expectedHymnID = 42
    var receivedHymnID: Int?

    notificationService.onNotificationTapped = { hymnID in
      receivedHymnID = hymnID
    }

    notificationService.simulateTap(hymnID: expectedHymnID)

    #expect(receivedHymnID, expectedHymnID, "onNotificationTapped should be called with the hymnID from notification")
  }

  @Test("testHymnServiceResolvesIndex", "HymnService resolves a HymnIndex for a known hymnID") func testHymnServiceResolvesIndex() {
    let hymnService = HymnService()

    guard let firstIndex = hymnService.hymnIndices.first else {
      fatalError("There must be at least one hymn index to test.")
    }

    let resolvedIndex = hymnService.hymnIndex(by: firstIndex.id)

    #require(resolvedIndex != nil, "hymnIndex(by:) should return a result for a known id")
    #expect(resolvedIndex?.id, firstIndex.id, "Resolved index must match the requested hymnID")
  }
}

// MARK: - Test Helpers

/// A lightweight shim to simulate the NotificationService behavior without importing UserNotifications
final class FakeNotificationService: NotificationService {
  /// Manually trigger the onNotificationTapped closure as if a notification was tapped
  func simulateTap(hymnID: Int) {
    onNotificationTapped?(hymnID)
  }
}
