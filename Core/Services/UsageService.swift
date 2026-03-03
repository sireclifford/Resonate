import Foundation
import Combine

final class UsageService: ObservableObject {
    
    struct HymnUsage: Codable {
        var count: Int
        var lastOpened: Date
    }
    
    @Published private(set) var usage: [Int: HymnUsage] = [:]
    
    private let storageKey = "hymn_usage_data"
    
    init() {
        load()
    }
    
    func increment(_ hymnID: Int) {
        let now = Date()
        
        if var existing = usage[hymnID] {
            existing.count += 1
            existing.lastOpened = now
            usage[hymnID] = existing
        } else {
            usage[hymnID] = HymnUsage(count: 1, lastOpened: now)
        }
        
        save()
    }
    
    func topHymns(limit: Int) -> [Int] {
        let now = Date()
        
        return usage
            .sorted { lhs, rhs in
                score(for: lhs.value, now: now) >
                score(for: rhs.value, now: now)
            }
            .prefix(limit)
            .map { $0.key }
    }
    
    private func score(for usage: HymnUsage, now: Date) -> Int {
        let days = Calendar.current.dateComponents([.day], from: usage.lastOpened, to: now).day ?? 0
        
        var boost = 0
        
        if days <= 1 {
            boost = 3
        } else if days <= 7 {
            boost = 2
        } else if days <= 30 {
            boost = 1
        }
        
        return usage.count + boost
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(usage) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Int: HymnUsage].self, from: data)
        else { return }
        
        usage = decoded
    }
}
