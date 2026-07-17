import Foundation

final class UserDefaultsReminderStateStore: ReminderStateStore {
    private let defaults: UserDefaults
    private let prefix = "notifications.snapshot."
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func loadSnapshot(for identifier: ReminderIdentifier) -> ReminderSnapshot? {
        guard let data = defaults.data(forKey: prefix + identifier.rawValue) else { return nil }
        
        do {
            return try JSONDecoder().decode(ReminderSnapshot.self, from: data)
        } catch {
            print("⚠️ Decode failed for key: \(identifier.rawValue), error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveSnapshot(_ snapshot: ReminderSnapshot) {
        do {
            let data = try JSONEncoder().encode(snapshot)
            defaults.set(data, forKey: prefix + snapshot.identifier.rawValue)
        } catch {
            print("⚠️ Encode failed for key: \(snapshot.identifier.rawValue), error: \(error.localizedDescription)")
        }
    }
    
    func removeSnapshot(for identifier: ReminderIdentifier) {
        defaults.removeObject(forKey: prefix + identifier.rawValue)
    }
}
