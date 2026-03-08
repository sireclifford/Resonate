import Foundation
import UserNotifications

struct NotificationRequestFactory {
    func makeRequest(
        payload: ReminderPayload,
        nextFireDate: Date,
        calendar: Calendar
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = payload.title
        content.subtitle = payload.subtitle ?? ""
        content.body = payload.body
        content.sound = payload.soundEnabled ? .default : nil
        content.userInfo = payload.userInfo
        if let badge = payload.badge {
            content.badge = NSNumber(value: badge)
        }

        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: nextFireDate
        )

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        return UNNotificationRequest(
            identifier: payload.identifier.rawValue,
            content: content,
            trigger: trigger
        )
    }
}
