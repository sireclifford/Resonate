import Foundation

//This lets me swap storage later without touching UI

final class UserDefaultsStore: PersistenceService {
    private let defaults = UserDefaults.standard
    
    func save<T: Codable>(_ value: T, for key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            defaults.set(data, forKey: key)
        } catch {
            print("⚠️ Encode failed for key \(key): \(error.localizedDescription)")
        }
    }
    
    func load<T: Codable>(_ type: T.Type, for key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("⚠️ Decode failed for key \(key): \(error.localizedDescription)")
            return nil
        }
    }
}
