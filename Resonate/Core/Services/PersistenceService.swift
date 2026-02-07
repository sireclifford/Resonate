protocol PersistenceService {
    func save<T: Codable>(_ value: T, for key: String)
    func load<T: Codable>(_ type: T.Type, for key: String) -> T?
}
