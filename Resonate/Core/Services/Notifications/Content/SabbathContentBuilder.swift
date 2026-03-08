import Foundation

struct SabbathContentBuilder: ReminderContentBuilding {
    func payload(for context: ReminderContext) -> ReminderPayload? {
        guard let _ = context.sabbathTime else { return nil }

        return ReminderPayload(
            identifier: .sabbathPrimary(),
            type: .sabbath,
            title: "Sabbath Reminder",
            subtitle: "Prepare your heart for worship",
            body: "The Sabbath is near. Pause, reflect, and draw near in worship.",
            soundEnabled: true,
            badge: nil,
            userInfo: [
                "type": ReminderType.sabbath.rawValue
            ]
        )
    }
}
