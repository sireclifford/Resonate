import Foundation

//This lets me swap storage later without touching UI

final class UserDefaultsStore: PersistenceService {
    private let defaults = UserDefaults.standard
    
    func save<T: Codable>(_ value: T, for key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }
    
    func load<T: Codable>(_ type: T.Type, for key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
}
