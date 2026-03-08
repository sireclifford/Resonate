import Foundation

struct HOTDContentBuilder: ReminderContentBuilding {
    func payload(for context: ReminderContext) -> ReminderPayload? {
        let hymnTitle = context.hotdTitle ?? "Hymn of the Day"

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

        return ReminderPayload(
            identifier: .hotdPrimary,
            type: .hymnOfTheDay,
            title: "Hymn of the Day",
            subtitle: subtitles.randomElement(),
            body: hymnTitle,
            soundEnabled: true,
            badge: nil,
            userInfo: [
                "type": ReminderType.hymnOfTheDay.rawValue,
                "hymnID": String(context.hotdHymnID ?? 0)
            ]
        )
    }
}
