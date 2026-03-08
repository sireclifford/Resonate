import Foundation

protocol ReminderScheduling {
    func syncHOTD(context: ReminderContext) async
    func syncSabbath(context: ReminderContext) async
    func cancel(identifier: ReminderIdentifier) async
}
