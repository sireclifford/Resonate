import Foundation

struct HymnOfTheDayEngine {
    private let calendar: Calendar
    private let occasionResolver: OccasionResolver
    private let anchorDate: Date
    private let globalSeed: UInt64

    init(
        calendar: Calendar = OccasionResolver.localGregorianCalendar,
        globalSeed: UInt64 = 2026
    ) {
        self.calendar = calendar
        self.occasionResolver = OccasionResolver(calendar: calendar)
        self.globalSeed = globalSeed

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = 2026
        components.month = 1
        components.day = 1
        self.anchorDate = calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }

    func hymnID(
        for date: Date,
        hymns: [HymnIndex],
        overrides: [HOTDOverride] = []
    ) -> Int? {
        guard !hymns.isEmpty else { return nil }

        if let overrideID = overrideHymnID(for: date, overrides: overrides) {
            return overrideID
        }

        let occasion = occasionResolver.occasion(for: date)
        let pool = poolForOccasion(occasion, from: hymns)

        if let occasionID = pickFromPool(pool, for: date, seed: seed(for: occasion)) {
            return occasionID
        }

        let fallbackPool = hymns.map(\.id).sorted()
        return pickFromPool(fallbackPool, for: date, seed: globalSeed)
    }

    private func overrideHymnID(for date: Date, overrides: [HOTDOverride]) -> Int? {
        let key = Self.dateFormatter.string(from: date)
        return overrides.first(where: { $0.date == key })?.hymnID
    }

    private func poolForOccasion(_ occasion: HymnOccasion, from hymns: [HymnIndex]) -> [Int] {
        switch occasion {
        case .regular:
            return hymns.map(\.id).sorted()

        case .sabbath:
            return hymns
                .filter { titleLooksLikeSabbath($0.title) || categoryLooksLikeWorship($0) }
                .map(\.id)
                .sorted()

        case .christmas:
            return hymns
                .filter { titleLooksLikeChristmas($0.title) }
                .map(\.id)
                .sorted()

        case .easter:
            return hymns
                .filter { titleLooksLikeEaster($0.title) }
                .map(\.id)
                .sorted()

        case .newYear:
            return hymns
                .filter { titleLooksLikeNewYear($0.title) }
                .map(\.id)
                .sorted()

        case .communion:
            return hymns
                .filter { titleLooksLikeCommunion($0.title) }
                .map(\.id)
                .sorted()
        }
    }

    private func pickFromPool(_ pool: [Int], for date: Date, seed: UInt64) -> Int? {
        guard !pool.isEmpty else { return nil }

        let ordered = seededShuffle(pool, seed: seed)
        let dayOffset = daysSinceAnchor(for: date)
        let index = ((dayOffset % ordered.count) + ordered.count) % ordered.count
        return ordered[index]
    }

    private func seededShuffle(_ values: [Int], seed: UInt64) -> [Int] {
        var generator = SeededGenerator(seed: seed)
        var copy = values
        copy.shuffle(using: &generator)
        return copy
    }

    private func daysSinceAnchor(for date: Date) -> Int {
        let start = calendar.startOfDay(for: anchorDate)
        let current = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: current).day ?? 0
    }

    private func seed(for occasion: HymnOccasion) -> UInt64 {
        switch occasion {
        case .regular: return globalSeed
        case .sabbath: return globalSeed &+ 101
        case .christmas: return globalSeed &+ 202
        case .easter: return globalSeed &+ 303
        case .newYear: return globalSeed &+ 404
        case .communion: return globalSeed &+ 505
        }
    }

    private func categoryLooksLikeWorship(_ hymn: HymnIndex) -> Bool {
        let raw = String(describing: hymn.category).lowercased()
        return raw.contains("worship") || raw.contains("praise")
    }

    private func titleLooksLikeSabbath(_ title: String) -> Bool {
        let t = title.lowercased()
        return t.contains("sabbath") || t.contains("holy day") || t.contains("rest")
    }

    private func titleLooksLikeChristmas(_ title: String) -> Bool {
        let t = title.lowercased()
        return t.contains("christmas") ||
               t.contains("bethlehem") ||
               t.contains("manger") ||
               t.contains("nativity") ||
               t.contains("born") ||
               t.contains("holy night")
    }

    private func titleLooksLikeEaster(_ title: String) -> Bool {
        let t = title.lowercased()
        return t.contains("resurrection") ||
               t.contains("risen") ||
               t.contains("calvary") ||
               t.contains("cross") ||
               t.contains("empty tomb") ||
               t.contains("lamb")
    }

    private func titleLooksLikeNewYear(_ title: String) -> Bool {
        let t = title.lowercased()
        return t.contains("new year") ||
               t.contains("consecration") ||
               t.contains("revive") ||
               t.contains("renew") ||
               t.contains("again")
    }

    private func titleLooksLikeCommunion(_ title: String) -> Bool {
        let t = title.lowercased()
        return t.contains("communion") ||
               t.contains("bread") ||
               t.contains("cup") ||
               t.contains("supper") ||
               t.contains("table") ||
               t.contains("calvary")
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = OccasionResolver.localGregorianCalendar
        formatter.timeZone = OccasionResolver.localGregorianCalendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
