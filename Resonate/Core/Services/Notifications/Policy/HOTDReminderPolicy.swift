import Foundation
import CryptoKit

struct HOTDReminderPolicy: ReminderPolicyEvaluating {
    private let dateProvider: DateProviding
    private let contentBuilder: ReminderContentBuilding
#if DEBUG
private let minimumSameDayBuffer: TimeInterval = 60
#else
private let minimumSameDayBuffer: TimeInterval = 2 * 60 * 60
//    private let minimumSameDayBuffer: TimeInterval = 60
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
            schedule: dailySchedule(from: context.hotdTime),
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
        
        guard let nextOccurrence = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: comps.hour, minute: comps.minute, second: 0),
            matchingPolicy: .nextTime
        ) else {
            return now.addingTimeInterval(24 * 60 * 60)
        }
        
        let timeUntilNext = nextOccurrence.timeIntervalSince(now)
        
        if timeUntilNext >= minimumSameDayBuffer {
            return nextOccurrence
        }
        
#if DEBUG
print("NOW:", now)
print("NEXT OCCURRENCE:", nextOccurrence)
print("TIME UNTIL NEXT:", timeUntilNext)
print("MINIMUM BUFFER:", minimumSameDayBuffer)
#endif
        
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        var tomorrowComps = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        tomorrowComps.hour = comps.hour
        tomorrowComps.minute = comps.minute
        tomorrowComps.second = 0
        
        return calendar.date(from: tomorrowComps) ?? nextOccurrence
    }
    
    private func dailySchedule(from time: Date) -> ReminderSchedule {
        let comps = dateProvider.calendar.dateComponents([.hour, .minute], from: time)
        return .daily(hour: comps.hour ?? 9, minute: comps.minute ?? 0)
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
