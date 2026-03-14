import Foundation
import CryptoKit

struct HOTDReminderPolicy: ReminderPolicyEvaluating {
    private let dateProvider: DateProviding
    private let contentBuilder: ReminderContentBuilding
#if DEBUG
    private let minimumSameDayBuffer: TimeInterval = 60
#else
    private let minimumSameDayBuffer: TimeInterval = 2 * 60 * 60
#endif
    
    init(
        dateProvider: DateProviding,
        contentBuilder: ReminderContentBuilding
    ) {
        self.dateProvider = dateProvider
        self.contentBuilder = contentBuilder
    }
    
    func evaluate(context: ReminderContext) -> ReminderDecision {
        guard context.hotdEnabled else {
            return .cancel(identifier: .hotdPrimary)
        }
        
        guard context.authorizationGranted else {
            return .suppress(reason: .permissionDenied)
        }
        
        guard let payload = contentBuilder.payload(for: context) else {
            return .suppress(reason: .noContentAvailable)
        }
        
        let nextFireDate: Date
        
        if context.hotdOpenedToday {
            nextFireDate = tomorrowTriggerDate(
                now: context.now,
                reminderTime: context.hotdTime,
                calendar: dateProvider.calendar
            )
        } else {
            nextFireDate = nextTriggerDate(
                now: context.now,
                reminderTime: context.hotdTime,
                calendar: dateProvider.calendar
            )
        }
        
        let snapshot = ReminderSnapshot(
            identifier: .hotdPrimary,
            type: .hymnOfTheDay,
            nextFireDate: nextFireDate,
            schedule: schedule(fromNextFireDate: nextFireDate, now: context.now),
            contentHash: payload.hashValueString
        )
        
        return .schedule(snapshot: snapshot, payload: payload)
    }
    
    private func tomorrowTriggerDate(
        now: Date,
        reminderTime: Date,
        calendar: Calendar
    ) -> Date {
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        let tomorrow = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: now)
        ) ?? now.addingTimeInterval(24 * 60 * 60)
        
        var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = 0
        
        return calendar.date(from: components) ?? tomorrow
    }
    
    private func nextTriggerDate(now: Date, reminderTime: Date, calendar: Calendar) -> Date {
        let comps = calendar.dateComponents([.hour, .minute], from: reminderTime)
        let roundedNow = calendar.date(
            from: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        ) ?? now
        
        guard let nextOccurrence = calendar.nextDate(
            after: roundedNow,
            matching: DateComponents(hour: comps.hour, minute: comps.minute, second: 0),
            matchingPolicy: .nextTime
        ) else {
            return now.addingTimeInterval(24 * 60 * 60)
        }
        
        let timeUntilNext = nextOccurrence.timeIntervalSince(roundedNow)
        
        if timeUntilNext >= minimumSameDayBuffer {
            return nextOccurrence
        }
        
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        var tomorrowComps = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        tomorrowComps.hour = comps.hour
        tomorrowComps.minute = comps.minute
        tomorrowComps.second = 0
        
        return calendar.date(from: tomorrowComps) ?? nextOccurrence
    }
    
    private func schedule(fromNextFireDate next: Date, now: Date) -> ReminderSchedule {
        let calendar = dateProvider.calendar
        let timeComponents = calendar.dateComponents([.hour, .minute], from: next)

        if calendar.isDate(next, inSameDayAs: now) {
            return .daily(hour: timeComponents.hour ?? 9, minute: timeComponents.minute ?? 0)
        }

        return .oneTime(on: next, calendar: calendar)
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
