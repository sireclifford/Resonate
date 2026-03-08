import Foundation

protocol ReminderStateStore {
    func loadSnapshot(for identifier: ReminderIdentifier) -> ReminderSnapshot?
    func saveSnapshot(_ snapshot: ReminderSnapshot)
    func removeSnapshot(for identifier: ReminderIdentifier)
}
