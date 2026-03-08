import Foundation

protocol DateProviding {
    var now: Date { get }
    var calendar: Calendar { get }
}

struct SystemDateProvider: DateProviding {
    var now: Date { Date() }
    var calendar: Calendar { Calendar.current }
}
