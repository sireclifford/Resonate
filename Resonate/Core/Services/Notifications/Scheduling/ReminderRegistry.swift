import Foundation

final class ReminderRegistry {
    private(set) var supportedTypes: [ReminderType] = [
        .hymnOfTheDay,
        .sabbath,
        .event,
        .seasonal,
        .promotional
    ]
}
