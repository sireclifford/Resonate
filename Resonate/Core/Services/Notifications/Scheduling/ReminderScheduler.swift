import Foundation
import UserNotifications

final class ReminderScheduler: ReminderScheduling {
    private let client: NotificationCenterClient
    private let requestFactory: NotificationRequestFactory
    private let stateStore: ReminderStateStore
    private let hotdPolicy: ReminderPolicyEvaluating
    private let dateProvider: DateProviding
    private let sabbathPolicy: ReminderPolicyEvaluating

    init(
        client: NotificationCenterClient,
        requestFactory: NotificationRequestFactory,
        stateStore: ReminderStateStore,
        hotdPolicy: ReminderPolicyEvaluating,
        sabbathPolicy: ReminderPolicyEvaluating,
        dateProvider: DateProviding
    ) {
        self.client = client
        self.requestFactory = requestFactory
        self.stateStore = stateStore
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

            let idsToClear = [normalizedSnapshot.identifier.rawValue, "daily_hymn_reminder"]


            await client.removePending(ids: idsToClear)
            await client.removeDelivered(ids: idsToClear)

            let repeats: Bool
            switch snapshot.schedule {
            case .daily, .weekly:
                repeats = true
            case .oneShot:
                repeats = false
            }

            let request = requestFactory.makeRequest(
                payload: payload,
                nextFireDate: snapshot.nextFireDate,
                calendar: dateProvider.calendar,
                repeats: repeats
            )

            do {
                try await client.add(request)

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
            idsToClear = [identifier.rawValue, "daily_hymn_reminder"]
        } else {
            idsToClear = [identifier.rawValue]
        }

        await client.removePending(ids: idsToClear)
        await client.removeDelivered(ids: idsToClear)
        stateStore.removeSnapshot(for: identifier)
    }
    
    private func normalizedSnapshotDate(_ date: Date) -> Date {
        let components = dateProvider.calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return dateProvider.calendar.date(from: components) ?? date
    }
}

