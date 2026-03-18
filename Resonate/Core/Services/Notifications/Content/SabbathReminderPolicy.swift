import Foundation
import CryptoKit

struct SabbathReminderPolicy: ReminderPolicyEvaluating {
    private let dateProvider: DateProviding
    private let contentBuilder: ReminderContentBuilding

    init(
        dateProvider: DateProviding,
        contentBuilder: ReminderContentBuilding
    ) {
        self.dateProvider = dateProvider
        self.contentBuilder = contentBuilder
    }

    func evaluate(context: ReminderContext) -> ReminderDecision {
        guard context.sabbathEnabled else {
            return .cancel(identifier: .sabbathPrimary())
        }

        guard context.authorizationGranted else {
            return .suppress(reason: .permissionDenied)
        }

        guard let reminderTime = context.sabbathTime else {
            return .suppress(reason: .noContentAvailable)
        }

        let nextFireDate = nextSabbathTriggerDate(
            now: context.now,
            reminderTime: reminderTime,
            calendar: dateProvider.calendar
        )

        guard let payload = contentBuilder.payload(for: context, scheduledFor: nextFireDate) else {
            return .suppress(reason: .noContentAvailable)
        }

        let snapshot = ReminderSnapshot(
            identifier: .sabbathPrimary(),
            type: .sabbath,
            nextFireDate: nextFireDate,
            schedule: weeklySchedule(from: reminderTime),
            contentHash: payload.hashValueString
        )
        
#if DEBUG
print("Scheduling Sabbath reminder")
print("Next fire date:", nextFireDate)
#endif

        return .schedule(snapshot: snapshot, payload: payload)
    }

    private func nextSabbathTriggerDate(
        now: Date,
        reminderTime: Date,
        calendar: Calendar
    ) -> Date {
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)

        var targetComponents = DateComponents()
        targetComponents.weekday = 6 // Friday in Gregorian calendar where Sunday = 1
        targetComponents.hour = timeComponents.hour
        targetComponents.minute = timeComponents.minute
        targetComponents.second = 0

        if let next = calendar.nextDate(
            after: now,
            matching: targetComponents,
            matchingPolicy: .nextTime,
            direction: .forward
        ) {
            return next
        }

        return now.addingTimeInterval(7 * 24 * 60 * 60)
    }

    private func weeklySchedule(from time: Date) -> ReminderSchedule {
        let components = dateProvider.calendar.dateComponents([.hour, .minute], from: time)
        return .weekly(
            weekday: 6,
            hour: components.hour ?? 18,
            minute: components.minute ?? 0
        )
    }
}

private extension ReminderPayload {
    var hashValueString: String {
        let joined = [
            identifier.rawValue,
            type.rawValue,
            title,
            subtitle ?? "",
            body,
            userInfo.keys.sorted().map { "\($0)=\(userInfo[$0] ?? "")" }.joined(separator: "&")
        ].joined(separator: "|")

        let digest = SHA256.hash(data: Data(joined.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
