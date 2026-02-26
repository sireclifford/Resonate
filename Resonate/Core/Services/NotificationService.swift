import UserNotifications
import Foundation
import Combine

final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    var onNotificationTapped: ((Int) -> Void)?
    
    override init() {
        super.init()
        print("NotificationService initialized")
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("Notification permission error:", error)
            }
        }
    }
    
    
    func scheduleSmartDailyReminder(
        reminderTime: Date,
        hymn: HymnIndex,
        engagementService: HymnOfTheDayEngagementService
    ) {
        cancelReminder()

        // If user already opened today's Hymn of the Day → suppress
        if engagementService.hasOpenedToday(hymnID: hymn.id) {
            print("Hymn of the Day already opened — suppressing reminder")
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

        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)

        // 👇 Calculate the next valid date (today or tomorrow)
        guard let nextTriggerDate = calendar.nextDate(
            after: Date(),
            matching: components,
            matchingPolicy: .nextTime
        ) else { return }

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: nextTriggerDate
            ),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "daily_hymn_reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error:", error)
            } else {
                print("Scheduled reminder for:", nextTriggerDate)
            }
        }
    }

    func cancelReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["daily_hymn_reminder"])
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

