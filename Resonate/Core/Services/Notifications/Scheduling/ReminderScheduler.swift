import Foundation

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
            let existing = stateStore.loadSnapshot(for: snapshot.identifier)

            if existing == snapshot {
                return
            }

            let idsToClear = [snapshot.identifier.rawValue, "daily_hymn_reminder"]

            await client.removePending(ids: idsToClear)
            await client.removeDelivered(ids: idsToClear)

            let request = requestFactory.makeRequest(
                payload: payload,
                nextFireDate: snapshot.nextFireDate,
                calendar: dateProvider.calendar
            )

            do {
#if DEBUG
                print("Scheduling HOTD reminder")
                print("Identifier:", snapshot.identifier.rawValue)
                print("Next fire date:", snapshot.nextFireDate)
                print("Schedule:", snapshot.schedule)
                print("Content hash:", snapshot.contentHash)
#endif
                
                try await client.add(request)
                stateStore.saveSnapshot(snapshot)
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
            let existing = stateStore.loadSnapshot(for: snapshot.identifier)

            if existing == snapshot {
                return
            }

            await client.removePending(ids: [snapshot.identifier.rawValue])
            await client.removeDelivered(ids: [snapshot.identifier.rawValue])

            let request = requestFactory.makeRequest(
                payload: payload,
                nextFireDate: snapshot.nextFireDate,
                calendar: dateProvider.calendar
            )
            
#if DEBUG
print("Scheduling Sabbath reminder")
print("Identifier:", snapshot.identifier.rawValue)
print("Next fire date:", snapshot.nextFireDate)
print("Schedule:", snapshot.schedule)
print("Content hash:", snapshot.contentHash)
#endif

            do {
                try await client.add(request)
                stateStore.saveSnapshot(snapshot)
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
}
