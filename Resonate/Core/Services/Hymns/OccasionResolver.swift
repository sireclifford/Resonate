import Foundation

struct OccasionResolver {
    private let calendar: Calendar

    init(calendar: Calendar = OccasionResolver.localGregorianCalendar) {
        self.calendar = calendar
    }

    func occasion(for date: Date) -> HymnOccasion {
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)

        if let month = components.month, let day = components.day {
            if month == 1 && day == 1 {
                return .newYear
            }

            if month == 12 && (day == 24 || day == 25) {
                return .christmas
            }
        }

        if isEasterSeason(date) {
            return .easter
        }

        if components.weekday == 7 {
            return .sabbath
        }

        return .regular
    }

    private func isEasterSeason(_ date: Date) -> Bool {
        let year = calendar.component(.year, from: date)
        guard let easter = easterSunday(year: year) else { return false }

        guard
            let goodFriday = calendar.date(byAdding: .day, value: -2, to: easter),
            let easterMonday = calendar.date(byAdding: .day, value: 1, to: easter)
        else {
            return false
        }

        let day = calendar.startOfDay(for: date)
        return day >= calendar.startOfDay(for: goodFriday) &&
               day <= calendar.startOfDay(for: easterMonday)
    }

    private func easterSunday(year: Int) -> Date? {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)
    }

    static let utcGregorianCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }()

    static let localGregorianCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }()
}
