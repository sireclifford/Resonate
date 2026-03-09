import UserNotifications
import Foundation
import Combine

final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    var onNotificationTapped: ((Int) -> Void)?
    private let dailyReminderID = "daily_hymn_reminder"
    
    override init() {
        super.init()
//        print("NotificationService initialized")
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
//                print("Notification permission error:", error)
            }
        }
    }
    
    
    func scheduleSmartDailyReminder(
        reminderTime: Date,
        hymn: HymnIndex,
        engagementService: HymnOfTheDayEngagementService,
        startFromTomorrow: Bool
    ) {
        let center = UNUserNotificationCenter.current()

        // Always clear any previously scheduled/delivered daily reminder to avoid duplicates
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderID])
        center.removeDeliveredNotifications(withIdentifiers: [dailyReminderID])

        // If user already opened today's Hymn of the Day → suppress
        if engagementService.hasOpenedToday(hymnID: hymn.id) {
//            print("Hymn of the Day already opened — suppressing reminder")
            return
        }
        
        let calendar = Calendar.current

        let content = UNMutableNotificationContent()

        let subtitles = [
            "Begin your day in worship",
            "A moment of praise awaits",
            "Pause and reflect",
            "Let your heart sing",
            "Start your day with devotion",
            "A hymn for your soul",
            "Lift your voice in praise",
            "Draw closer in worship"
        ]

        content.title = "Hymn of the Day"
        content.subtitle = subtitles.randomElement() ?? "Begin your day in worship"
        content.body = hymn.title
        content.sound = .default
        content.userInfo = ["hymnID": hymn.id]

        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)

        let nextTriggerDate: Date

        if startFromTomorrow {
            // Always schedule for *tomorrow* at the chosen time (avoid double-touching users on day 1).
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) ?? Date()
            var comps = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            comps.hour = timeComponents.hour
            comps.minute = timeComponents.minute
            comps.second = 0
            nextTriggerDate = calendar.date(from: comps) ?? tomorrow
        } else {
            // Schedule for the next occurrence (today if still ahead, otherwise tomorrow).
            guard let next = calendar.nextDate(
                after: Date(),
                matching: DateComponents(hour: timeComponents.hour, minute: timeComponents.minute, second: 0),
                matchingPolicy: .nextTime
            ) else { return }
            nextTriggerDate = next
        }

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: nextTriggerDate
            ),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: dailyReminderID,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let  error = error {
//                print("Notification scheduling error:", error)
            } else {
//                print("Scheduled reminder for:", nextTriggerDate)
            }
        }
    }

    func cancelReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderID])
        center.removeDeliveredNotifications(withIdentifiers: [dailyReminderID])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if let hymnID = userInfo["hymnID"] as? Int {
            DispatchQueue.main.async {
                self.onNotificationTapped?(hymnID)
            }
        }

        completionHandler()
    }
}
