import Foundation

struct HOTDContentBuilder: ReminderContentBuilding {
    private let hymnService: HymnService

    init(hymnService: HymnService) {
        self.hymnService = hymnService
    }

    func payload(for context: ReminderContext, scheduledFor fireDate: Date?) -> ReminderPayload? {
        let scheduledHymn = fireDate.flatMap { hymnService.hymnOfTheDay(on: $0) }
        let hymnTitle = scheduledHymn?.title ?? context.hotdTitle ?? "Hymn of the Day"
        let hymnID = scheduledHymn?.id ?? context.hotdHymnID ?? 0

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
                "hymnID": String(hymnID)
            ]
        )
    }
}
