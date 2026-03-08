import Foundation

protocol ReminderPolicyEvaluating {
    func evaluate(context: ReminderContext) -> ReminderDecision
}
