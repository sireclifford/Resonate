import Foundation
import UserNotifications

struct NotificationRequestFactory {
    func makeRequest(
        payload: ReminderPayload,
        nextFireDate: Date,
        calendar: Calendar,
        repeats: Bool
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

        let trigger: UNCalendarNotificationTrigger
        if repeats {
            let hm = calendar.dateComponents([.hour, .minute], from: nextFireDate)
            var components = DateComponents()
            components.hour = hm.hour
            components.minute = hm.minute
            components.second = 0
            components.timeZone = calendar.timeZone
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        } else {
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextFireDate)
            components.timeZone = calendar.timeZone
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        }

        return UNNotificationRequest(
            identifier: payload.identifier.rawValue,
            content: content,
            trigger: trigger
        )
    }
    
    func makeWeeklyRequest(
        payload: ReminderPayload,
        firstFireDate: Date,
        calendar: Calendar,
        weekday: Int
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

        let hm = calendar.dateComponents([.hour, .minute], from: firstFireDate)
        var components = DateComponents()
        components.weekday = weekday // 1=Sunday ... 7=Saturday per Calendar
        components.hour = hm.hour
        components.minute = hm.minute
        components.second = 0
        components.timeZone = calendar.timeZone

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        return UNNotificationRequest(
            identifier: payload.identifier.rawValue,
            content: content,
            trigger: trigger
        )
    }
}
