import Foundation
import UserNotifications

final class ReminderScheduler: ReminderScheduling {
    private let hotdSchedulingHorizonDays = 7
    private let client: NotificationCenterClient
    private let requestFactory: NotificationRequestFactory
    private let stateStore: ReminderStateStore
    private let hotdContentBuilder: ReminderContentBuilding
    private let hotdPolicy: ReminderPolicyEvaluating
    private let dateProvider: DateProviding
    private let sabbathPolicy: ReminderPolicyEvaluating

    init(
        client: NotificationCenterClient,
        requestFactory: NotificationRequestFactory,
        stateStore: ReminderStateStore,
        hotdContentBuilder: ReminderContentBuilding,
        hotdPolicy: ReminderPolicyEvaluating,
        sabbathPolicy: ReminderPolicyEvaluating,
        dateProvider: DateProviding
    ) {
        self.client = client
        self.requestFactory = requestFactory
        self.stateStore = stateStore
        self.hotdContentBuilder = hotdContentBuilder
        self.hotdPolicy = hotdPolicy
        self.sabbathPolicy = sabbathPolicy
        self.dateProvider = dateProvider
    }

    func syncHOTD(context: ReminderContext) async {
        let decision = hotdPolicy.evaluate(context: context)

        switch decision {
        case .none:
            return

        case .suppress:
            await cancel(identifier: .hotdPrimary)

        case .cancel(let identifier):
            await cancel(identifier: identifier)

        case .schedule(let snapshot, let payload):
            let normalizedSnapshot = ReminderSnapshot(
                identifier: snapshot.identifier,
                type: snapshot.type,
                nextFireDate: normalizedSnapshotDate(snapshot.nextFireDate),
                schedule: snapshot.schedule,
                contentHash: snapshot.contentHash
            )

            let existing = stateStore.loadSnapshot(for: normalizedSnapshot.identifier)

            if existing == normalizedSnapshot {
                return
            }

            if await shouldPreserveCommittedTodayHOTD(
                existing: existing,
                requested: normalizedSnapshot,
                context: context
            ) {
                return
            }

            let pendingHOTDIdentifiers = await pendingHOTDRequestIdentifiers()
            if !pendingHOTDIdentifiers.isEmpty {
                await client.removePending(ids: pendingHOTDIdentifiers)
            }

            do {
                let requests = hotdRequests(from: snapshot.nextFireDate, context: context, fallbackPayload: payload)

                for request in requests {
                    try await client.add(request)
                }

                stateStore.saveSnapshot(normalizedSnapshot)
            } catch {
                print("Failed to add request:", error)
            }
        }
    }
    
    func syncSabbath(context: ReminderContext) async {
        let decision = sabbathPolicy.evaluate(context: context)

        switch decision {
        case .none:
            return

        case .suppress:
            await cancel(identifier: .sabbathPrimary())

        case .cancel(let identifier):
            await cancel(identifier: identifier)

        case .schedule(let snapshot, let payload):
            let normalizedSnapshot = ReminderSnapshot(
                identifier: snapshot.identifier,
                type: snapshot.type,
                nextFireDate: normalizedSnapshotDate(snapshot.nextFireDate),
                schedule: snapshot.schedule,
                contentHash: snapshot.contentHash
            )

            let existing = stateStore.loadSnapshot(for: normalizedSnapshot.identifier)

            if existing == normalizedSnapshot {
                return
            }

            await client.removePending(ids: [normalizedSnapshot.identifier.rawValue])
            await client.removeDelivered(ids: [normalizedSnapshot.identifier.rawValue])

            let weekday = dateProvider.calendar.component(.weekday, from: snapshot.nextFireDate)
            let request = requestFactory.makeWeeklyRequest(
                payload: payload,
                firstFireDate: snapshot.nextFireDate,
                calendar: dateProvider.calendar,
                weekday: weekday
            )

            do {
                try await client.add(request)

                stateStore.saveSnapshot(normalizedSnapshot)
            } catch {
                print("Failed to schedule Sabbath reminder:", error)
            }
        }
    }

    func cancel(identifier: ReminderIdentifier) async {
        let idsToClear: [String]

        if identifier == .hotdPrimary {
            idsToClear = await pendingHOTDRequestIdentifiers()
        } else {
            idsToClear = [identifier.rawValue]
        }

        if !idsToClear.isEmpty {
            await client.removePending(ids: idsToClear)
            await client.removeDelivered(ids: idsToClear)
        }
        stateStore.removeSnapshot(for: identifier)
    }
    
    private func normalizedSnapshotDate(_ date: Date) -> Date {
        let components = dateProvider.calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return dateProvider.calendar.date(from: components) ?? date
    }

    private func hotdRequests(
        from firstFireDate: Date,
        context: ReminderContext,
        fallbackPayload: ReminderPayload
    ) -> [UNNotificationRequest] {
        let calendar = dateProvider.calendar

        return upcomingHOTDFireDates(startingAt: firstFireDate).compactMap { fireDate in
            let payload = hotdContentBuilder.payload(for: context, scheduledFor: fireDate) ?? fallbackPayload
            let requestIdentifier = hotdRequestIdentifier(for: fireDate, calendar: calendar)

            return requestFactory.makeRequest(
                requestIdentifier: requestIdentifier,
                payload: payload,
                nextFireDate: fireDate,
                calendar: calendar,
                repeats: false
            )
        }
    }

    private func upcomingHOTDFireDates(startingAt firstFireDate: Date) -> [Date] {
        let calendar = dateProvider.calendar
        return (0..<hotdSchedulingHorizonDays).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: firstFireDate)
        }
    }

    private func hotdRequestIdentifier(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return "\(ReminderIdentifier.hotdPrimary.rawValue).\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
    }

    private func pendingHOTDRequestIdentifiers() async -> [String] {
        let pendingRequests = await client.pendingRequests()

        return pendingRequests
            .map(\.identifier)
            .filter { identifier in
                identifier == "daily_hymn_reminder" ||
                identifier.hasPrefix(ReminderIdentifier.hotdPrimary.rawValue)
            }
    }

    private func shouldPreserveCommittedTodayHOTD(
        existing: ReminderSnapshot?,
        requested: ReminderSnapshot,
        context: ReminderContext
    ) async -> Bool {
        guard let existing else { return false }

        let calendar = dateProvider.calendar
        guard calendar.isDate(existing.nextFireDate, inSameDayAs: context.now) else { return false }
        guard existing.nextFireDate > context.now else { return false }
        guard !calendar.isDate(requested.nextFireDate, inSameDayAs: context.now) else { return false }

        let existingTime = calendar.dateComponents([.hour, .minute], from: existing.nextFireDate)
        let selectedTime = calendar.dateComponents([.hour, .minute], from: context.hotdTime)
        guard existingTime.hour == selectedTime.hour, existingTime.minute == selectedTime.minute else {
            return false
        }

        let existingIdentifier = hotdRequestIdentifier(for: existing.nextFireDate, calendar: calendar)
        let pendingIdentifiers = await pendingHOTDRequestIdentifiers()
        return pendingIdentifiers.contains(existingIdentifier)
    }
}
