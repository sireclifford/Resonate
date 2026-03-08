import Foundation

final class UserDefaultsReminderStateStore: ReminderStateStore {
    private let defaults: UserDefaults
    private let prefix = "notifications.snapshot."

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSnapshot(for identifier: ReminderIdentifier) -> ReminderSnapshot? {
        guard let data = defaults.data(forKey: prefix + identifier.rawValue) else { return nil }
        return try? JSONDecoder().decode(ReminderSnapshot.self, from: data)
    }

    func saveSnapshot(_ snapshot: ReminderSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: prefix + snapshot.identifier.rawValue)
    }

    func removeSnapshot(for identifier: ReminderIdentifier) {
        defaults.removeObject(forKey: prefix + identifier.rawValue)
    }
}
